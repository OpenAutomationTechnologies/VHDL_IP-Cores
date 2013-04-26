LIBRARY ieee;
USE ieee.std_logic_1164.all;
USE ieee.std_logic_arith.all;
USE ieee.std_logic_unsigned.all;

use work.global.all;

entity tbPdiSpi is
end entity tbPdiSpi;

architecture bhv of tbPdiSpi is
    signal rst, clk, done : std_logic;
    signal spiClk, spiClk_s, spiSel, spiMiso, spiMosi : std_logic;
    
    signal masterReg, masterLoadData : std_logic_vector(7 downto 0);
    signal masterLoad, masterShift : std_logic;
    signal masterShiftCnt : std_logic_vector(3 downto 0);
    alias masterShiftDone : std_logic is masterShiftCnt(masterShiftCnt'left);
    signal masterDout : std_logic_vector(7 downto 0);
    
    procedure master_doShift (
        vLoadVal : in std_logic_vector(7 downto 0);
        signal shift : out std_logic;
        signal load : out std_logic;
        signal loadData : out std_logic_vector(7 downto 0);
        signal done : in std_logic
    ) is
    begin
        load <= cActivated;
        loadData <= vLoadVal;
        wait for 100 ns;
        load <= cInactivated;
        shift <= cActivated;
        wait until done = cActivated;
        wait for 100 ns;
        shift <= cInactivated;
    end procedure;
begin
    theMainClkGen : entity work.clkgen
        generic map (
            gPeriod => 20 ns
        )
        port map (
            iDone => done,
            oClk => clk
        );
    
    rst <= cActivated, cInactivated after 100 ns;
    
    theSpiClkGen : entity work.clkgen
        generic map (
            gPeriod => 1000 ns
        )
        port map (
            iDone => done,
            oClk => spiClk_s
        );
    
    spiClk <= spiClk_s after 10 ns when spiSel = cActivated else cInactivated;
        
    theMasterSreg : process(rst, spiClk, masterLoad, masterShiftDone)
    begin
        if masterLoad = cActivated then
            masterReg <= masterLoadData;
        elsif masterShiftDone = cActivated then
            masterShiftCnt <= (others => cInactivated) after 100 ns;
            masterDout <= masterReg;
        elsif rst = cActivated then
            masterReg <= (others => cInactivated);
            masterDout <= (others => cInactivated);
            masterShiftCnt <= (others => cInactivated);
        elsif falling_edge(spiClk) then
            if masterShift = cActivated then
                masterReg <= masterReg(masterReg'left-1 downto 0) & spiMiso;
                masterShiftCnt <= std_logic_vector(unsigned(masterShiftCnt)+1);
            end if;
        end if;
    end process;
    
    spiMosi <= masterReg(masterReg'left);
    spiSel <= masterShift;
    
    theStim : process
    begin
        masterLoad <= cInactivated;
        masterLoadData <= (others => cInactivated);
        masterShift <= cInactivated;
        done <= cInactivated;
        wait until rst = cInactivated;
        
        -- test for inverse
        for i in 0 to 255 loop
            wait until spiClk_s'event;
            wait until rising_edge(clk);
            master_doShift(conv_std_logic_vector(i, 8), masterShift, masterLoad, masterLoadData, masterShiftDone);
        end loop;
        
        --wake up
        wait until spiClk_s'event;
        wait until rising_edge(clk);
        master_doShift(x"03", masterShift, masterLoad, masterLoadData, masterShiftDone);
        
        wait until spiClk_s'event;
        wait until rising_edge(clk);
        master_doShift(x"0A", masterShift, masterLoad, masterLoadData, masterShiftDone);
        
        wait until spiClk_s'event;
        wait until rising_edge(clk);
        master_doShift(x"0C", masterShift, masterLoad, masterLoadData, masterShiftDone);
        
        wait until spiClk_s'event;
        wait until rising_edge(clk);
        master_doShift(x"0F", masterShift, masterLoad, masterLoadData, masterShiftDone);
        
        wait until spiClk_s'event;
        wait until rising_edge(clk);
        --??
        
        done <= cActivated;
        wait;
    end process;
    
    theDUT : entity work.pdi_spi
        generic map (
            spiSize_g => 8,
            cpol_g => false,
            cpha_g => false,
            spiBigEnd_g => false
        )
        port map (
            spi_clk => spiClk,
            spi_sel => spiSel,
            spi_miso => spiMiso,
            spi_mosi => spiMosi,
            ap_reset => rst,
            ap_clk => clk,
            ap_chipselect => open,
            ap_read => open,
            ap_write => open,
            ap_byteenable => open,
            ap_address => open,
            ap_writedata => open,
            ap_readdata => (others => cInactivated)
        );
end architecture bhv;
