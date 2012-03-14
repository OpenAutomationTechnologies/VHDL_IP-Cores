library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_textio.all;
use global.all;

entity tbMasterTestDevice is
    generic (
        gSlaveAddrWidth : natural := 16;
        gSlaveDataWidth : natural := 32;
        gMasterAddrWidth : natural := 32;
        gMasterDataWidth : natural := 32;
        gMasterBurstCountWidth : natural := 10
    );
end tbMasterTestDevice;

architecture bhv of tbMasterTestDevice is
	-- DUT
	component mastertestdevice
		generic(
		gSlaveAddrWidth : natural := 16;
		gSlaveDataWidth : natural := 32;
		gMasterAddrWidth : natural := 32;
		gMasterDataWidth : natural := 32;
		gMasterBurstCountWidth : natural := 10 );
	port(
		iClk : in STD_LOGIC;
		iRst : in STD_LOGIC;
		iSlaveChipselect : in STD_LOGIC;
		iSlaveWrite : in STD_LOGIC;
		iSlaveRead : in STD_LOGIC;
		iSlaveAddress : in STD_LOGIC_VECTOR(gSlaveAddrWidth-1 downto 0);
		iSlaveWritedata : in STD_LOGIC_VECTOR(gSlaveDataWidth-1 downto 0);
		oSlaveReaddata : out STD_LOGIC_VECTOR(gSlaveDataWidth-1 downto 0);
		oSlaveWaitrequest : out STD_LOGIC;
		oMasterWrite : out STD_LOGIC;
		oMasterRead : out STD_LOGIC;
		oMasterAddress : out STD_LOGIC_VECTOR(gMasterAddrWidth-1 downto 0);
		oMasterWritedata : out STD_LOGIC_VECTOR(gMasterDataWidth-1 downto 0);
		iMasterReaddata : in STD_LOGIC_VECTOR(gMasterDataWidth-1 downto 0);
		iMasterWaitrequest : in STD_LOGIC;
		iMasterReaddatavalid : in STD_LOGIC;
		oMasterBurstcount : out STD_LOGIC_VECTOR(gMasterBurstCountWidth-1 downto 0);
        oMasterBurstCounter : out std_logic_vector(gMasterBurstCountWidth-1 downto 0));
	end component;

	-- Stimulus signals - signals mapped to the input and inout ports of tested entity
	signal iClk : STD_LOGIC;
	signal iRst : STD_LOGIC;
	signal iSlaveChipselect : STD_LOGIC;
	signal iSlaveWrite : STD_LOGIC;
	signal iSlaveRead : STD_LOGIC;
	signal iSlaveAddress : STD_LOGIC_VECTOR(gSlaveAddrWidth-1 downto 0);
	signal iSlaveWritedata : STD_LOGIC_VECTOR(gSlaveDataWidth-1 downto 0);
	signal iMasterReaddata : STD_LOGIC_VECTOR(gMasterDataWidth-1 downto 0);
	signal iMasterWaitrequest : STD_LOGIC;
	signal iMasterReaddatavalid : STD_LOGIC;
	-- Observed signals - signals mapped to the output ports of tested entity
	signal oSlaveReaddata : STD_LOGIC_VECTOR(gSlaveDataWidth-1 downto 0);
	signal oSlaveWaitrequest : STD_LOGIC;
	signal oMasterWrite : STD_LOGIC;
	signal oMasterRead : STD_LOGIC;
	signal oMasterAddress : STD_LOGIC_VECTOR(gMasterAddrWidth-1 downto 0);
	signal oMasterWritedata : STD_LOGIC_VECTOR(gMasterDataWidth-1 downto 0);
	signal oMasterBurstcount : STD_LOGIC_VECTOR(gMasterBurstCountWidth-1 downto 0);
    
    constant cFirePattern : natural := 16#A#;
    
    signal slaveIfTestRun : boolean := false;
    signal slaveIfTestDone : boolean := false;
    signal slaveIfTestError : boolean := false;
    
    signal masterIfTestRun : boolean := false;
    signal masterIfTestDone : boolean := false;
    signal masterIfTestError : boolean := false;
    
    signal testDone : boolean := false;
    signal testError : boolean := false;

begin
    
    --simulation done/error
    testError <= slaveIfTestError or masterIfTestError;
    testDone <= slaveIfTestDone and masterIfTestDone after 100 ns;
    assert (not (testDone and testError)) report "--- Simulation done with error(s) ---" severity error;
    assert (not (testDone and not testError)) report "--- Simulation done ---" severity note;
    
    --simulation run
    slaveIfTestRun <= not slaveIfTestDone and true;
    masterIfTestRun <= not masterIfTestDone and slaveIfTestDone; --start master if test after slave if test
    
    clkGen : process
    begin
        iClk <= cInactivated;
        wait for 5 ns;
        iClk <= not iClk;
        wait for 5 ns;
        if testDone then
            wait;
        end if;
    end process;
    
    rstGen : process
    begin
        assert (false) report "--- Simulation started ---" severity note;
        iRst <= cActivated;
        wait for 100 ns;
        iRst <= not iRst;
        wait;
    end process;
    
    slaveIfTest : process(iClk)
        variable vCounter : natural := 0;
        variable vSlaveAddress : integer := 0;
        constant cRevision : natural := 1;
        constant cControlValue : natural := 16#E#; --cont, burst, read
        --constant cControlValue : natural := 16#A#; --cont, read
        --constant cControlValue : natural := 16#6#; --burst, read
        --constant cControlValue : natural := 16#D#; --cont, burst, write
        constant cFireValue : natural := 16#5#;
        constant cBaseAddressPingValue : natural := 16#1200#;
        constant cBaseAddressPongValue : natural := 16#8800#;
        constant cBurstSizeValue : natural := 16#10#;
        constant cTimeoutValue : natural := 16#5#;
    begin
        if rising_edge(iClk) and not slaveIfTestDone then
            if iRst = cActivated then
                slaveIfTestDone <= false;
                iSlaveChipselect <= cInactivated;
                iSlaveWrite <= cInactivated;
                iSlaveRead <= cInactivated;
                iSlaveAddress <= (others => cInactivated);
                iSlaveWritedata <= (others => cInactivated);
                vCounter := 0;
            elsif slaveIfTestRun then
                --default
                iSlaveChipselect <= cInactivated;
                iSlaveWrite <= cInactivated;
                iSlaveRead <= cInactivated;
                
                if vCounter = 0 then
                    --write to registers
                    iSlaveChipselect <= cActivated;
                    iSlaveWrite <= cActivated;
                    case to_integer(unsigned(iSlaveAddress) + 1) is
                        when 3 =>
                            --control
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cControlValue, iSlaveWritedata'length));
                        when 4 =>
                            --fire
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cFireValue, iSlaveWritedata'length));
                        when 5 =>
                            --baseAddress
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBaseAddressPingValue, iSlaveWritedata'length));
                        when 6 =>
                            --baseAddress
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBaseAddressPongValue, iSlaveWritedata'length));
                        when 7 =>
                            --burstSize
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBurstSizeValue, iSlaveWritedata'length));
                        when 8 =>
                            --timeout
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cTimeoutValue, iSlaveWritedata'length));
                        when 10 =>
                            --write done, move to next
                            vCounter := vCounter + 1;
                            iSlaveChipselect <= cInactivated;
                            iSlaveWrite <= cInactivated;
                            iSlaveAddress <= (others => '0');
                        when others =>
                            --RO;
                    end case;
                    if oSlaveWaitrequest = '0' and vCounter = 0 then
                        iSlaveAddress <= std_logic_vector(unsigned(iSlaveAddress) + 1);
                    end if;
                elsif vCounter = 1 then
                    --read from registers
                    --write to registers
                    iSlaveChipselect <= cActivated;
                    iSlaveRead <= cActivated;
                    case to_integer(unsigned(iSlaveAddress)) is
                        when 0 =>
                            --revision
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (false) report 
                                "Either revision or Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cRevision, iSlaveWritedata'length));
                        when 3 =>
                            --control
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cControlValue, iSlaveWritedata'length));
                        when 4 =>
                            --fire
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cFireValue, iSlaveWritedata'length));
                        when 5 =>
                            --baseAddressPing
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBaseAddressPingValue, iSlaveWritedata'length));
                        when 6 =>
                            --baseAddressPing
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBaseAddressPongValue, iSlaveWritedata'length));
                        when 7 =>
                            --burstSize
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cBurstSizeValue, iSlaveWritedata'length));
                        when 8 =>
                            --timeout
                            if oSlaveWaitrequest /= cActivated and oSlaveReaddata /= iSlaveWritedata then
                                assert (oSlaveReaddata = iSlaveWritedata) report 
                                "Readdata is wrong @ address " & integer'IMAGE(to_integer(unsigned(iSlaveAddress))) severity error;
                                slaveIfTestError <= true;
                            end if;
                            iSlaveWritedata <= std_logic_vector(to_unsigned(cTimeoutValue, iSlaveWritedata'length));
                        when 10 =>
                            --write done, move to next
                            vCounter := vCounter + 1;
                            iSlaveChipselect <= cInactivated;
                            iSlaveRead <= cInactivated;
                        when others =>
                            --RO;
                    end case;
                    if oSlaveWaitrequest = '0' and vCounter = 1 then
                        iSlaveAddress <= std_logic_vector(unsigned(iSlaveAddress) + 1);
                    end if;
                elsif vCounter = 2 then
                    --write fire pattern to start transfer
                    iSlaveChipselect <= cActivated;
                    iSlaveWrite <= cActivated;
                    iSlaveAddress <= std_logic_vector(to_unsigned(4, iSlaveAddress'length));
                    iSlaveWritedata <= std_logic_vector(to_unsigned(cFirePattern, iSlaveWritedata'length));
                    assert (false) report "--- Slave Interface Test: Write FIRE command ---" severity note;
                    if oSlaveWaitrequest = '0' then
                        vCounter := vCounter + 1;
                    end if;
                else
                    assert (false) report "--- Slave Interface Test passed successfully ---" severity note;
                    slaveIfTestDone <= true;
                end if;
            end if;
        end if;
    end process;
    
    masterIfTest : process(iClk)
        variable vTimeout : natural := 0;
        -- constants (note in comments the difference to the "real timeout" is shown)
        constant cTimeout1stWrite : natural := 6; -- +3
        constant cTimeout1stRead : natural := 10;
        constant cTimeoutWrite : natural := 1; -- +1
        constant cTimeoutRead : natural := 3;
        variable vTransferCounter : natural := 0;
        type sMasterIfTest is (idle, write, readRequest, read);
        variable fsm, fsmNext : sMasterIfTest;
    begin
        if rising_edge(iClk) and not masterIfTestDone then
            if iRst = cActivated then
                iMasterReaddata <= (others => cInactivated);
                iMasterWaitrequest <= cActivated;
                iMasterReaddatavalid <= cInactivated;
                masterIfTestDone <= false;
                vTimeout := 0;
                vTransferCounter := 0;
                fsm := idle;
            elsif masterIfTestRun then
                if fsm /= idle and fsmNext = idle then
                    --masterIfTestError <= true;
                    assert (false) report "--- Master Interface Test passed successfully ---" severity note;
                    masterIfTestDone <= true;
                end if;
                --default
                fsm := fsmNext;
                iMasterWaitrequest <= cActivated;
                iMasterReaddatavalid <= cInactivated;
                
                if iMasterReaddatavalid = cActivated then
                    iMasterReaddata <= std_logic_vector(unsigned(iMasterReaddata) + 1);
                end if;
                
                case fsm is
                    when idle =>
                        vTransferCounter := to_integer(unsigned(oMasterBurstcount));
                        if oMasterWrite = cActivated then
                            fsmNext := write;
                            vTimeout := cTimeout1stWrite;
                        elsif oMasterRead = cActivated then
                            fsmNext := readRequest;
                            vTimeout := cTimeout1stRead;
                        end if;
                    when write =>
                        if vTimeout = 0 then
                            iMasterWaitrequest <= cInactivated;
                            if vTransferCounter = 1 then
                                fsmNext := idle;
                            else
                                vTimeout := cTimeoutWrite;
                                vTransferCounter := vTransferCounter - 1;
                            end if;
                        else
                            vTimeout := vTimeout - 1;
                        end if;
                    when readRequest =>
                        if vTimeout = 0 then
                            iMasterWaitrequest <= cInactivated;
                            vTimeout := cTimeoutRead;
                            fsmNext := read;
                        else
                            vTimeout := vTimeout - 1;
                        end if;
                    when read =>
                        if vTimeout = 0 then
                            iMasterReaddatavalid <= cActivated;
                            if vTransferCounter = 1 then
                                fsmNext := idle;
                            else
                                vTimeout := cTimeoutRead;
                                vTransferCounter := vTransferCounter - 1;
                            end if;
                        else
                            vTimeout := vTimeout - 1;
                        end if;
                end case;
            end if;
        end if;
    end process;
    
	DUT : mastertestdevice
		generic map (
			gSlaveAddrWidth => gSlaveAddrWidth,
			gSlaveDataWidth => gSlaveDataWidth,
			gMasterAddrWidth => gMasterAddrWidth,
			gMasterDataWidth => gMasterDataWidth,
			gMasterBurstCountWidth => gMasterBurstCountWidth
		)

		port map (
			iClk => iClk,
			iRst => iRst,
			iSlaveChipselect => iSlaveChipselect,
			iSlaveWrite => iSlaveWrite,
			iSlaveRead => iSlaveRead,
			iSlaveAddress => iSlaveAddress,
			iSlaveWritedata => iSlaveWritedata,
			oSlaveReaddata => oSlaveReaddata,
			oSlaveWaitrequest => oSlaveWaitrequest,
			oMasterWrite => oMasterWrite,
			oMasterRead => oMasterRead,
			oMasterAddress => oMasterAddress,
			oMasterWritedata => oMasterWritedata,
			iMasterReaddata => iMasterReaddata,
			iMasterWaitrequest => iMasterWaitrequest,
			iMasterReaddatavalid => iMasterReaddatavalid,
			oMasterBurstcount => oMasterBurstcount,
            oMasterBurstCounter => open --don't care
		);

end bhv;

configuration TESTBENCH_FOR_mastertestdevice of tbMasterTestDevice is
	for bhv
		for DUT : mastertestdevice
			use entity work.mastertestdevice(rtl);
		end for;
	end for;
end TESTBENCH_FOR_mastertestdevice;

