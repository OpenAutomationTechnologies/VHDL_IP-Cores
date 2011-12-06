#------------------------------------------------------------------------------------------------------------------------
#-- POWERLINK XPS PLB Component (TCL)
#--
#-- 	  Copyright (C) 2011 B&R
#--
#--    Redistribution and use in source and binary forms, with or without
#--    modification, are permitted provided that the following conditions
#--    are met:
#--
#--    1. Redistributions of source code must retain the above copyright
#--       notice, this list of conditions and the following disclaimer.
#--
#--    2. Redistributions in binary form must reproduce the above copyright
#--       notice, this list of conditions and the following disclaimer in the
#--       documentation and/or other materials provided with the distribution.
#--
#--    3. Neither the name of B&R nor the names of its
#--       contributors may be used to endorse or promote products derived
#--       from this software without prior written permission. For written
#--       permission, please contact office@br-automation.com
#--
#--    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
#--    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
#--    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
#--    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
#--    COPYRIGHT HOLDERS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
#--    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
#--    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
#--    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
#--    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#--    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
#--    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
#--    POSSIBILITY OF SUCH DAMAGE.
#--
#------------------------------------------------------------------------------------------------------------------------
#-- Version History
#------------------------------------------------------------------------------------------------------------------------
#-- 2011-11-18	V0.01	zelenkaj	converted to first stable solution with MAC-layer only
#-- 2011-11-01	V0.02	mairt	added procedures for the powerlink gui
#------------------------------------------------------------------------------------------------------------------------

#uses "xillib.tcl"

proc generate {drv_handle} {
	puts "POWERLINK IP-Core found!"
	xdefine_include_file $drv_handle "xparameters.h" "plb_powerlink" "C_MAC_REG_BASEADDR" "C_MAC_REG_HIGHADDR" "C_MAC_CMP_BASEADDR" "C_MAC_CMP_HIGHADDR" "C_MAC_PKT_BASEADDR" "C_MAC_PKT_HIGHADDR" "C_TX_INT_PKT" "C_RX_INT_PKT"
}  	

###################################################
## internal procedures
###################################################
proc calc_rx_tx_buffer_size { tx_needed } {
 	set macPktLength	4
	# tx buffer header (header + packet length)
	set macTxHd			[expr  0 + $macPktLength]
	# rx buffer header (header + packet length)
	set macRxHd 		[expr 26 + $macPktLength]
	# max rx buffers
	set macRxBuffers 	16
	# max tx buffers
	set macTxBuffers	16
	# mtu by ieee
	set mtu 			1500
	# eth header
	set ethHd			14
	# crc size by ieee
	set crc				4
	# min data size of a packet
	set minDatSize		46
	# min packet size (ethheader + mindata + crc + tx buffer header)
	set minPktBufSize	[expr $ethHd + $minDatSize + $crc + $macTxHd]
	# max packet size (ethheader + mtu + crc + tx buffer header)
	set maxPktBufSize	[expr $ethHd + $mtu + $crc + $macTxHd]
	
		#calc tx packet size
	set IdRes 	[expr 176 				+ $crc + $macTxHd]
	set StRes 	[expr 72 				+ $crc + $macTxHd]
	set NmtReq 	[expr $ethHd + $mtu		+ $crc + $macTxHd]
	set nonEpl	[expr $ethHd + $mtu		+ $crc + $macTxHd]
	set PRes	[expr 24 + $tpdo0size	+ $crc + $macTxHd]
	#sync response for poll-resp-ch (44 bytes + padding = 60bytes)
	set SyncRes [expr 60				+ $crc + $macTxHd]
	
	if {$PRes < $minPktBufSize} {
		#PRes buffer is smaller 64 bytes => padding!
		set PRes $minPktBufSize
	}
	
	#the following error is catched by the allowed range of pdo size
	if {$PRes > $maxPktBufSize} {
		error "TPDO Size is too large. Allowed Range 1...1490 bytes!"
	}
	
	#align all tx buffers
	set IdRes 	[expr ($IdRes + 3) & ~3]
	set StRes 	[expr ($StRes + 3) & ~3]
	set NmtReq 	[expr ($NmtReq + 3) & ~3]
	set nonEpl 	[expr ($nonEpl + 3) & ~3]
	set PRes 	[expr ($PRes + 3) & ~3]
	set SyncRes [expr ($SyncRes + 3) & ~3]
	
	#calculate tx buffer size out of tpdos and other packets
	set txBufSize [expr $IdRes + $StRes + $NmtReq + $nonEpl + $PRes + $SyncRes]
	set macTxBuffers 6
	
	#openPOWERLINK allocates TX buffers twice (ping-pong)
	set txBufSize [expr $txBufSize * 2]
	set macTxBuffers [expr $macTxBuffers * 2]
	
	#calculate rx buffer size out of packets per cycle
	set rxBufSize [expr $ethHd + $mtu + $crc + $macRxHd]
	set rxBufSize [expr ($rxBufSize + 3) & ~3]
	set rxBufSize [expr $macRxBuffers * $rxBufSize]
	
	if { $tx_needed == true} {
	 	return txBufSize
	} else {
	    return rxBufSize
	}
}

###################################################
## IP-Core mode calculation
###################################################
# get if pdi should be generated in the ip-core
proc get_pdi_enable { param_handle }	{

  	set mhsinst      [xget_hw_parent_handle $param_handle]
    set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	
	if {$ipcore_mode > 0 && $ipcore_mode < 5} {
	   return true
	} else {
	   return false
	}
}  
	
# check if the parallel interface is enabled
proc get_par_if_enable { param_handle }	{

  	set mhsinst      [xget_hw_parent_handle $param_handle]
    set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	
	if {$ipcore_mode == 1} {
	   return true
	} else {
	   return false
	}
}	

# check if the SPI interface is enabled
proc get_spi_if_enable { param_handle }	{

  	set mhsinst      [xget_hw_parent_handle $param_handle]
    set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	
	if {$ipcore_mode == 3} {
	   return true
	} else {
	   return false
	}
}

# check if the plb bus interface is enabled
proc get_plb_bus_enable { param_handle }	{

  	set mhsinst      [xget_hw_parent_handle $param_handle]
    set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	
	if {$ipcore_mode == 4} {
	   return true
	} else {
	   return false
	}
}


# check if the simple IO interface is enabled
proc get_simple_io_enable { param_handle }	{

  	set mhsinst      [xget_hw_parent_handle $param_handle]
    set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	
	if {$ipcore_mode == 0} {
	   return true
	} else {
	   return false
	}
} 

###################################################
## calculate packet location
###################################################
proc update_tx_packet_location { param_handle} {
	
	set mhsinst      [xget_hw_parent_handle $param_handle]
    set packet_location   [xget_hw_parameter_value $mhsinst "C_PACKET_LOCATION"] 

	if {$packet_location == 0} {
		# TX is in DPRAM
		return true
	} elseif  {$packet_location == 1} {
		# TX is in DPRAM
		return true
	} else { 
		# TX is in external RAM
		return false 
	}
}	 

proc update_rx_packet_location { param_handle} {
	
	set mhsinst      [xget_hw_parent_handle $param_handle]
    set packet_location   [xget_hw_parameter_value $mhsinst "C_PACKET_LOCATION"] 

	if {$packet_location == 0} {
		# RX is in DPRAM
	   	return true
	} elseif  {$packet_location == 1} {
		# RX is in external RAM
		return false
	} else { 
		# RX is in external RAM
		return false 
	}
} 

###################################################
## MAC Packet size calculation
###################################################			 
proc calc_mac_packet_size { param_handle } {

	set mhsinst      [xget_hw_parent_handle $param_handle]	
	set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	set pack_loc   [xget_hw_parameter_value $mhsinst "C_PACKET_LOCATION"] 	
	
	if {$ipcore_mode == 5} {
		#openMAC only
		set rxBufSize   [xget_hw_parameter_value $mhsinst "C_MAC_PKT_SIZE_RX_USER"] 	
		set txBufSize   [xget_hw_parameter_value $mhsinst "C_MAC_PKT_SIZE_TX_USER"] 			
	} else {  
		# PDI or simple IO is used
		set txBufSize [ calc_rx_tx_buffer_size true ]
		set rxBufSize [ calc_rx_tx_buffer_size false ]
	}
	
	if { $pack_loc == 0 } {
		#TX and RX into DPRAM
		set macBufSize [expr $txBufSize + $rxBufSize]
	} elseif {$pack_loc == 1} {
		#TX into DPRAM and RX over PLB
		set macBufSize $txBufSize
	} elseif {$pack_loc == 2} {
		#TX and RX over PLB
		set macBufSize 0
	} else {
	 	#should not happen
		error "Packet location invalid! (Should not happen)" "" "mdt_error"
	}

	return $macBufSize
}

proc calc_mac_packet_size_log2 { param_handle } {
	set mhsinst      [xget_hw_parent_handle $param_handle]	
	set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	set pack_loc   [xget_hw_parameter_value $mhsinst "C_PACKET_LOCATION"] 
	
	if {$ipcore_mode == 5} {
		#openMAC only
		set rxBufSize   [xget_hw_parameter_value $mhsinst "C_MAC_PKT_SIZE_RX_USER"] 	
		set txBufSize   [xget_hw_parameter_value $mhsinst "C_MAC_PKT_SIZE_TX_USER"] 			
	} else {  
		# PDI or simple IO is used
		set txBufSize [ calc_rx_tx_buffer_size true ]
		set rxBufSize [ calc_rx_tx_buffer_size false ]
	}
	
	if { $pack_loc == 0 } {
		#TX and RX into DPRAM
		set macBufSize [expr $txBufSize + $rxBufSize]
		set log2MacBufSize [expr int(ceil(log($macBufSize) / log(2.)))]
	} elseif {$pack_loc == 1} {
		#TX into DPRAM and RX over PLB
		set macBufSize $txBufSize
		set log2MacBufSize [expr int(ceil(log($macBufSize) / log(2.)))]
	} elseif {$pack_loc == 2} {
		#TX and RX over PLB
		set log2MacBufSize 3
	} else {
	 	#should not happen
		error "Packet location invalid! (Should not happen)" "" "mdt_error"
	}  

	return $log2MacBufSize	
}

###################################################
## PDO Buffer size calculation
###################################################			 
# calc rpdo 0 buffer size
proc calc_rpdo_0_buffer_size { param_handle} {
	set returnVal 0

	set mhsinst      [xget_hw_parent_handle $param_handle]		  
   set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
   set buffer_size   [xget_hw_parameter_value $mhsinst "C_PDI_RPDO_BUF_SIZE_USER"]
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		# header + 4 bytes real data 
		set returnVal [ expr 4 + 16 ] 
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]		
	} else {  
		# PDI is used
		# add header
		set returnVal [ expr $buffer_size + 16 ]
	}
		   
	return $returnVal
	
} 	  

proc calc_rpdo_1_buffer_size { param_handle} {
	set returnVal 0

	set mhsinst      		[xget_hw_parent_handle $param_handle]		  
   set ipcore_mode   		[xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	set buffer_count_mac  	[xget_hw_parameter_value $mhsinst "C_MAC_NUM_RPDO_USER"] 
   set buffer_size   		[xget_hw_parameter_value $mhsinst "C_PDI_RPDO_BUF_SIZE_USER"]
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		if {$buffer_count_mac < 2} {
			# buffer deactivated
			set returnVal [ expr 0 ] 
		} else { 
			# header + 4 bytes real data
			set returnVal [ expr 4 + 16 ] 
		}
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]		
	} else {	 
		# PDI is used
		# add header
		set returnVal [ expr $buffer_size + 16 ] 
	}
		   
	return $returnVal
	
} 	 

proc calc_rpdo_2_buffer_size { param_handle} {
	set returnVal 0

	set mhsinst [xget_hw_parent_handle $param_handle]		  
   set ipcore_mode [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
	set buffer_count_mac [xget_hw_parameter_value $mhsinst "C_MAC_NUM_RPDO_USER"] 
   set buffer_size [xget_hw_parameter_value $mhsinst "C_PDI_RPDO_BUF_SIZE_USER"]
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		if {$buffer_count_mac < 3} {
		   # buffer deactivated
			set returnVal [ expr 0 ] 
		} else { 	
			# header + 4 bytes real data
			set returnVal [ expr 4 + 16 ] 
		} 
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]					
	} else {	 
		# PDI is used
		# add header
		set returnVal [ expr $buffer_size + 16 ]
	}
		   
	return $returnVal
	
} 	

# calc tpdo buffer size
proc calc_tpdo_buffer_size { param_handle} {
	set returnVal 0

	set mhsinst      [xget_hw_parent_handle $param_handle]	 
	set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"] 
    set param1val   [xget_hw_parameter_value $mhsinst "C_PDI_TPDO_BUF_SIZE_USER"]
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		# just 4 bytes real data 
		set returnVal [ expr 4 ]  
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]			
	} else {
		set returnVal [ expr $param1val + 16 ]
	}
	
	return $returnVal
} 

###################################################
## Calc RPDO and TPDO count
###################################################	
proc calc_rpdo_count { param_handle} {
	set returnVal 0

	set mhsinst      	[xget_hw_parent_handle $param_handle]
	set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"]	
	set rpdo_count_mac	[xget_hw_parameter_value $mhsinst "C_MAC_NUM_RPDO_USER"]
	set rpdo_count_pdi	[xget_hw_parameter_value $mhsinst "C_PDI_NUM_RPDO_USER"] 
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		set returnVal $rpdo_count_mac
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]		
	} else {  
		#pdi is used
	    set returnVal $rpdo_count_pdi
	}
	
	return $returnVal
}

proc calc_tpdo_count { param_handle} {
	set returnVal 0

	set mhsinst      [xget_hw_parent_handle $param_handle]
	set ipcore_mode   [xget_hw_parameter_value $mhsinst "ipcore_mode_g"]	
   set tpdo_count_mac	[xget_hw_parameter_value $mhsinst "C_MAC_NUM_TPDO_USER"]
	set tpdo_count_pdi	[xget_hw_parameter_value $mhsinst "C_PDI_NUM_TPDO_USER"]
	
	if {$ipcore_mode == 0} {
		#DirectIO is used
		set returnVal $tpdo_count_mac					
	} elseif {$ipcore_mode == 5} {
		#openMAC only
		set returnVal [ expr 0 ]					
	} else {  
		#pdi is used
	    set returnVal $tpdo_count_pdi
	}
	
	return $returnVal
}