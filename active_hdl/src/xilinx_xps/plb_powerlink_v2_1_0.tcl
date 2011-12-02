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
## PDO Buffer size calculation
###################################################
# calc tpdo buffer size
proc calc_tpdo_buffer_size { param_handle} {
	set returnVal 0

	set mhsinst      [xget_hw_parent_handle $param_handle]
    set param1val   [xget_hw_parameter_value $mhsinst "C_PDI_TPDO_BUF_SIZE"]
	
	set returnVal [ expr $param1val + 16 ]
		   
	return $returnVal
	
} 



