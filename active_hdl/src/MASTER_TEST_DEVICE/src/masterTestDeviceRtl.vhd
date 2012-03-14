------------------------------------------------------------------------------------------------------------------------
-- MASTER TEST DEVICE
--
-- 	  Copyright (C) 2012 B&R
--
--    Redistribution and use in source and binary forms, with or without
--    modification, are permitted provided that the following conditions
--    are met:
--
--    1. Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--
--    2. Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--
--    3. Neither the name of B&R nor the names of its
--       contributors may be used to endorse or promote products derived
--       from this software without prior written permission. For written
--       permission, please contact office@br-automation.com
--
--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
--    POSSIBILITY OF SUCH DAMAGE.
--
--
------------------------------------------------------------------------------------------------------------------------
-- Version History
------------------------------------------------------------------------------------------------------------------------
-- 2012-02-07   zelenkaj    Initial creation
-- 2012-02-27   zelenkaj    Added timestamp for last transfer
------------------------------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.global.all;

entity masterTestDevice is
    generic (
        --slave interface
        gSlaveAddrWidth : natural := 16;
        gSlaveDataWidth : natural := 32;
        --master interface
        gMasterAddrWidth : natural := 32;
        gMasterDataWidth : natural := 32;
        gMasterBurstCountWidth : natural := 10
        );
    port (
        iClk : in std_logic;
        iRst : in std_logic;
        --salve interface
        iSlaveChipselect : in std_logic;
        iSlaveWrite : in std_logic;
        iSlaveRead : in std_logic;
        iSlaveAddress : in std_logic_vector(gSlaveAddrWidth-1 downto 0);
        iSlaveWritedata : in std_logic_vector(gSlaveDataWidth-1 downto 0);
        oSlaveReaddata : out std_logic_vector(gSlaveDataWidth-1 downto 0);
        oSlaveWaitrequest : out std_logic;
        --master interface
        oMasterWrite : out std_logic;
        oMasterRead : out std_logic;
        oMasterAddress : out std_logic_vector(gMasterAddrWidth-1 downto 0);
        oMasterWritedata : out std_logic_vector(gMasterDataWidth-1 downto 0);
        iMasterReaddata : in std_logic_vector(gMasterDataWidth-1 downto 0);
        iMasterWaitrequest : in std_logic;
        iMasterReaddatavalid : in std_logic;
        oMasterBurstcount : out std_logic_vector(gMasterBurstCountWidth-1 downto 0);
        oMasterBurstCounter : out std_logic_vector(gMasterBurstCountWidth-1 downto 0)
         );
end masterTestDevice;

architecture rtl of masterTestDevice is
    --define common clock and reset
    signal clk : std_logic;
    signal rst : std_logic;
    
    ------------------------------------------------------------------------------------------------------------------------
    --slave interface
    constant cRevision : natural := 1;
    -- register length
    constant cTimeTickWidth : natural := 32;
    constant cStateRegWidth : natural := 4;
    constant cControlRegWidth : natural := 4;
    constant cFireRegWidth : natural := 4;
    constant cTimeoutWidth : natural := 32;
    -- fire constant
    constant cFirePattern : std_logic_vector(cFireRegWidth-1 downto 0) := std_logic_vector(to_unsigned(16#A#, cFireRegWidth));
    -- records
    --  state register
    type tSlaveState is record
        done : std_logic;
        busy : std_logic;
        --timeout : std_logic;
        --error : std_logic;
    end record;
    --  control register
    type tSlaveControl is record
        write : std_logic;
        read : std_logic;
        burst : std_logic;
        continuous : std_logic;
    end record;
    --  slave register
    type tSlave is record
        timeTick : std_logic_vector(cTimeTickWidth-1 downto 0);
        state : tSlaveState;
        control : tSlaveControl;
        fire : std_logic_vector(cFireRegWidth-1 downto 0);
        baseAddressPing : std_logic_vector(gMasterAddrWidth-1 downto 0);
        baseAddressPong : std_logic_vector(gMasterAddrWidth-1 downto 0);
        burstSize : std_logic_vector(gMasterBurstCountWidth-1 downto 0);
        timeout : std_logic_vector(cTimeoutWidth-1 downto 0);
        min1stLatency : std_logic_vector(cTimeTickWidth-1 downto 0);
        max1stLatency : std_logic_vector(cTimeTickWidth-1 downto 0);
        minTransLength : std_logic_vector(cTimeTickWidth-1 downto 0);
        maxTransLength : std_logic_vector(cTimeTickWidth-1 downto 0);
    end record;
    -- define register initialization
    constant cInitSlave : tSlave := (
        timeTick => (others => cInactivated),
        state => (others => cInactivated),
        control => (others => cInactivated),
        fire => (others => cInactivated),
        baseAddressPing => (others => '0'),
        baseAddressPong => (others => '0'),
        burstSize => (others => '0'),
        timeout => (others => '0'),
        min1stLatency => (others => '1'),
        max1stLatency => (others => '0'),
        minTransLength => (others => '1'),
        maxTransLength => (others => '0')
    );
    -- signals
    signal slaveReg, slaveRegNext : tSlave;
    signal slaveAckWr : std_logic;
    signal slaveAckRd, slaveAckRdNext : std_logic;
    
    ------------------------------------------------------------------------------------------------------------------------
    --master interface
    -- fsm type
    type tMasterFsm is (idle, write, readRequest, read, timeout);
    -- record
    --  master register
    type tMaster is record
        fsm : tMasterFsm;
        transferCounter : std_logic_vector(gMasterBurstCountWidth-1 downto 0);
        timeoutCounter : std_logic_vector(cTimeoutWidth-1 downto 0);
        transfer1stDone : boolean;
        timeTickReq : std_logic_vector(cTimeTickWidth-1 downto 0);
        timeTick1stTransfer : std_logic_vector(cTimeTickWidth-1 downto 0);
        timeTickLastTransfer : std_logic_vector(cTimeTickWidth-1 downto 0);
        baseAddrSelect : std_logic;
    end record;
    -- define register initialization
    constant cInitMaster : tMaster := (
        fsm => idle,
        transferCounter => (others => '0'),
        timeoutCounter => (others => '0'),
        transfer1stDone => false,
        timeTickReq => (others => '0'),
        timeTick1stTransfer => (others => '0'),
        timeTickLastTransfer => (others => '0'),
        baseAddrSelect => cInactivated
    );
    -- signals
    signal masterReg, masterRegNext : tMaster;
    signal timeTick1stDiffReq : std_logic_vector(cTimeTickWidth-1 downto 0); -- = timeTick1stTransfer - timeTickReq
    signal timeTickLastDiffReq : std_logic_vector(cTimeTickWidth-1 downto 0); -- = timeTickLastTransfer - timeTickReq
    signal timeTick1stDiffReqValid : std_logic;
    signal timeTickLastDiffReqValid : std_logic;
begin
    
    clk <= iClk;
    rst <= iRst;
    
    seq : process(clk)
    begin
        if rising_edge(clk) then
            if rst = cActivated then
                slaveReg <= cInitSlave;
                slaveAckRd <= cInactivated;
                masterReg <= cInitMaster;
            else
                slaveReg <= slaveRegNext;
                slaveAckRd <= slaveAckRdNext;
                masterReg <= masterRegNext;
            end if;
        end if;
    end process seq;
    
    oSlaveWaitrequest <= not(slaveAckWr or slaveAckRd);
    
    comb : process(masterReg, iMasterReaddata, iMasterWaitrequest, iMasterReaddatavalid,
        slaveReg, slaveAckRd, iSlaveChipselect, iSlaveWrite, iSlaveRead, iSlaveAddress, iSlaveWritedata,
        timeTick1stDiffReq, timeTick1stDiffReqValid, timeTickLastDiffReq, timeTickLastDiffReqValid)
    begin
        ------------------------------------------------------------------------------------------------------------------------
        --MASTER
        --default
        masterRegNext <= masterReg;
        slaveRegNext <= slaveReg; --slave logic is shared with master
        timeTick1stDiffReqValid <= cInactivated;
        timeTickLastDiffReqValid <= cInactivated;
        oMasterWrite <= cInactivated;
        oMasterRead <= cInactivated;
        oMasterWritedata <= (others => '0');
        
        if masterReg.fsm = write then
            oMasterWrite <= cActivated;
        end if;
        
        if masterReg.fsm = readRequest then
            oMasterRead <= cActivated;
        end if;
        
        oMasterWritedata(masterReg.transferCounter'range) <= masterReg.transferCounter;
        
        if masterReg.baseAddrSelect = cInactivated then
            oMasterAddress <= slaveReg.baseAddressPing;
        else
            oMasterAddress <= slaveReg.baseAddressPong;
        end if;
        
        if slaveReg.control.burst = cActivated then
            oMasterBurstcount <= slaveReg.burstSize;
        else
            oMasterBurstcount <= std_logic_vector(to_unsigned(1, oMasterBurstcount'length));
        end if;
        
        oMasterBurstCounter <= masterReg.transferCounter;
        
        timeTick1stDiffReq <= std_logic_vector(unsigned(masterReg.timeTick1stTransfer) - unsigned(masterReg.timeTickReq));
        timeTickLastDiffReq <= std_logic_vector(unsigned(masterReg.timeTickLastTransfer) - unsigned(masterReg.timeTickReq));
        
        case masterReg.fsm is
            when idle =>
                masterRegNext.transferCounter <= (others => '0');
                masterRegNext.timeTickReq <= (others => '0');
                masterRegNext.timeTick1stTransfer <= (others => '0');
                masterRegNext.timeTickLastTransfer <= (others => '0');
                
                if slaveReg.control.continuous = cActivated then
                    --if continuous transfer pulse the done bit
                    slaveRegNext.state.done <= cInactivated;
                end if;
                
                if slaveReg.fire = cFirePattern and 
                    (slaveReg.control.continuous = cActivated or (slaveReg.control.continuous = cInactivated and
                     slaveReg.state.done = cInactivated)) then
                    
                    if slaveReg.control.burst = cActivated then
                        masterRegNext.transferCounter <= slaveReg.burstSize; --get burst size
                    else
                        --single transfer
                        masterRegNext.transferCounter <= std_logic_vector(to_unsigned(1, masterRegNext.transferCounter'length));
                    end if;
                    
                    masterRegNext.timeTickReq <= slaveReg.timeTick; --get current time tick
                    masterRegNext.transfer1stDone <= false; --reset first transfer flag
                    
                    if slaveReg.control.read = cActivated then
                        masterRegNext.fsm <= readRequest;
                    elsif slaveReg.control.write = cActivated then
                        masterRegNext.fsm <= write;
                    end if;
                    
                end if;
                
            when write =>
                if iMasterWaitrequest = cInactivated then
                    masterRegNext.transferCounter <= std_logic_vector(unsigned(masterReg.transferCounter) - 1);
                    
                    if not masterReg.transfer1stDone then
                        --this is the very first complete transfer
                        masterRegNext.timeTick1stTransfer <= slaveReg.timeTick;
                        masterRegNext.transfer1stDone <= true;
                    end if;
                    
                    if masterReg.transferCounter = std_logic_vector(to_unsigned(1, masterReg.transferCounter'length)) then
                        masterRegNext.fsm <= timeout;
                        masterRegNext.timeTickLastTransfer <= slaveReg.timeTick;
                        masterRegNext.timeoutCounter <= slaveReg.timeout;
                        slaveRegNext.state.done <= cActivated;
                    end if;
                end if;
                
            when readRequest =>
                if iMasterWaitrequest = cInactivated then
                    masterRegNext.fsm <= read;
                end if;
                
            when read =>
                if iMasterReaddatavalid = cActivated then
                    masterRegNext.transferCounter <= std_logic_vector(unsigned(masterReg.transferCounter) - 1);
                    
                    if not masterReg.transfer1stDone then
                        --this is the very first complete transfer
                        masterRegNext.timeTick1stTransfer <= slaveReg.timeTick;
                        masterRegNext.transfer1stDone <= true;
                    end if;
                    
                    if masterReg.transferCounter = std_logic_vector(to_unsigned(1, masterReg.transferCounter'length)) then
                        masterRegNext.fsm <= timeout;
                        masterRegNext.timeTickLastTransfer <= slaveReg.timeTick;
                        masterRegNext.timeoutCounter <= slaveReg.timeout;
                        slaveRegNext.state.done <= cActivated;
                    end if;
                end if;
                
            when timeout =>
                if slaveReg.control.continuous = cActivated then
                    if masterReg.timeoutCounter = std_logic_vector(to_unsigned(0, masterReg.timeoutCounter'length)) then
                        masterRegNext.fsm <= idle;
                        timeTick1stDiffReqValid <= cActivated;
                        timeTickLastDiffReqValid <= cActivated;
                        masterRegNext.baseAddrSelect <= not masterReg.baseAddrSelect;
                    else
                        masterRegNext.timeoutCounter <= std_logic_vector(unsigned(masterReg.timeoutCounter) - 1);
                    end if;
                else
                    masterRegNext.fsm <= idle;
                    timeTick1stDiffReqValid <= cActivated;
                    timeTickLastDiffReqValid <= cActivated;
                    masterRegNext.baseAddrSelect <= not masterReg.baseAddrSelect;
                end if;
        end case;
    
        ------------------------------------------------------------------------------------------------------------------------
        --SLAVE
        --default
        --is shared with master logic => moved to top of this process!
        --slaveRegNext <= slaveReg;
        slaveAckWr <= cInactivated;
        slaveAckRdNext <= cInactivated;
        oSlaveReaddata <= (others => '0');
        
        --generate time tick (runs like a free-range chicken)
        slaveRegNext.timeTick <= std_logic_vector(unsigned(slaveReg.timeTick) + 1);
        
        if masterReg.fsm /= idle then
            --master is busy
            slaveRegNext.state.busy <= cActivated;
        else
            slaveRegNext.state.busy <= cInactivated;
        end if;
        
        --get max or min value
        if timeTick1stDiffReqValid = cActivated then
            --min
            if slaveReg.min1stLatency > timeTick1stDiffReq then
                slaveRegNext.min1stLatency <= timeTick1stDiffReq;
            end if;
            --max
            if slaveReg.max1stLatency < timeTick1stDiffReq then
                slaveRegNext.max1stLatency <= timeTick1stDiffReq;
            end if;
        end if;
        
        if timeTickLastDiffReqValid = cActivated then
            --min
            if slaveReg.minTransLength > timeTickLastDiffReq then
                slaveRegNext.minTransLength <= timeTickLastDiffReq;
            end if;
            --max
            if slaveReg.maxTransLength < timeTickLastDiffReq then
                slaveRegNext.maxTransLength <= timeTickLastDiffReq;
            end if;
        end if;
        
        if iSlaveChipselect = cActivated then
            --generate immediate write ack
            if iSlaveWrite = cActivated then
                slaveAckWr <= cActivated;
            end if;
            
            --generate read ack with one cycle delay
            if iSlaveRead = cActivated and slaveAckRd = cInactivated then
                slaveAckRdNext <= cActivated;
            else
                slaveAckRdNext <= cInactivated;
            end if;
            
            case to_integer(unsigned(iSlaveAddress)) is
                when 0 =>
                    --revision (RO)
                    oSlaveReaddata <= std_logic_vector(to_unsigned(cRevision, oSlaveReaddata'length));
                
                when 1 =>
                    --time tick (RO)
                    oSlaveReaddata <= slaveReg.timeTick;
                    
                when 2 =>
                    --state (RW)
                    oSlaveReaddata(0) <= slaveReg.state.done;
                    oSlaveReaddata(1) <= slaveReg.state.busy;
                    --oSlaveReaddata(2) <= slaveReg.state.timeout;
                    --oSlaveReaddata(3) <= slaveReg.state.error;
                    
                    if iSlaveWrite = cActivated then
                        --clear state bits
                        slaveRegNext.state.done <= slaveReg.state.done and not iSlaveWritedata(0);
                        --slaveRegNext.state.busy <= slaveReg.state.busy and not iSlaveWritedata(1);
                        --slaveRegNext.state.timeout <= slaveReg.state.timeout and not iSlaveWritedata(2);
                        --slaveRegNext.state.error <= slaveReg.state.error and not iSlaveWritedata(3);
                    end if;
                    
                when 3 =>
                    --control (RW)
                    oSlaveReaddata(0) <= slaveReg.control.write;
                    oSlaveReaddata(1) <= slaveReg.control.read;
                    oSlaveReaddata(2) <= slaveReg.control.burst;
                    oSlaveReaddata(3) <= slaveReg.control.continuous;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.control.write <= iSlaveWritedata(0);
                        slaveRegNext.control.read <= iSlaveWritedata(1);
                        slaveRegNext.control.burst <= iSlaveWritedata(2);
                        slaveRegNext.control.continuous <= iSlaveWritedata(3);
                    end if;
                    
                when 4 =>
                    --fire (RW)
                    oSlaveReaddata(slaveReg.fire'range) <= slaveReg.fire;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.fire <= iSlaveWritedata(slaveReg.fire'range);
                    end if;
                    
                when 5 =>
                    --baseAddressPing (RW)
                    oSlaveReaddata(slaveReg.baseAddressPing'range) <= slaveReg.baseAddressPing;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.baseAddressPing <= iSlaveWritedata(slaveReg.baseAddressPing'range);
                    end if;
                
                when 6 =>
                    --baseAddressPong (RW)
                    oSlaveReaddata(slaveReg.baseAddressPong'range) <= slaveReg.baseAddressPong;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.baseAddressPong <= iSlaveWritedata(slaveReg.baseAddressPong'range);
                    end if;
                    
                when 7 =>
                    --burstSize (RW)
                    oSlaveReaddata(slaveReg.burstSize'range) <= slaveReg.burstSize;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.burstSize <= iSlaveWritedata(slaveReg.burstSize'range);
                    end if;
                    
                when 8 =>
                    --timeout (RW)
                    oSlaveReaddata(slaveReg.timeout'range) <= slaveReg.timeout;
                    
                    if iSlaveWrite = cActivated then
                        slaveRegNext.timeout <= iSlaveWritedata(slaveReg.timeout'range);
                    end if;
                    
                when 9 =>
                    --min1stLatency (RO/WC)
                    oSlaveReaddata <= slaveReg.min1stLatency;
                    
                    if iSlaveWrite = cActivated then
                        --write to that register resets the value
                        slaveRegNext.min1stLatency <= cInitSlave.min1stLatency;
                    end if;
                    
                when 10 =>
                    --max1stLatency (RO/WC)
                    oSlaveReaddata <= slaveReg.max1stLatency;
                    if iSlaveWrite = cActivated then
                        --write to that register resets the value
                        slaveRegNext.max1stLatency <= cInitSlave.max1stLatency;
                    end if;
                
                when 11 =>
                    --minTransLength (RO/WC)
                    oSlaveReaddata <= slaveReg.minTransLength;
                    
                    if iSlaveWrite = cActivated then
                        --write to that register resets the value
                        slaveRegNext.minTransLength <= cInitSlave.minTransLength;
                    end if;
                    
                when 12 =>
                    --maxTransLength (RO/WC)
                    oSlaveReaddata <= slaveReg.maxTransLength;
                    
                    if iSlaveWrite = cActivated then
                        --write to that register resets the value
                        slaveRegNext.maxTransLength <= cInitSlave.maxTransLength;
                    end if;
                    
                when others =>
            end case;
        end if;
    end process;
    
end rtl;
