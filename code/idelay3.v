`timescale 1ns / 1ps


module idelay3(
    input  wire        reset,
    input  wire        ref_signal,
    input  wire  [8:0] i_cnt_value,
    input  wire        ref_clk_400m,
    
    output wire        ref_signal_fine,
    output wire        o_idelay_rdy
    );
    
        
    IDELAYCTRL #(
       .SIM_DEVICE("ULTRASCALE")  // Set the device version for simulation functionality (ULTRASCALE)
    )
    IDELAYCTRL_inst (
       .RDY(o_idelay_rdy),       // 1-bit output: Ready output
       .REFCLK(ref_clk_400m), // 1-bit input: Reference clock input
       .RST(reset)        // 1-bit input: Active-High reset input. Asynchronous assert, synchronous deassert to
                        // REFCLK.
    );

    // End of IDELAYCTRL_inst instantiation
    
    IDELAYE3 #(
       .CASCADE("NONE"),               // Cascade setting (MASTER, NONE, SLAVE_END, SLAVE_MIDDLE)
       .DELAY_FORMAT("TIME"),          // Units of the DELAY_VALUE (COUNT, TIME)
       .DELAY_SRC("DATAIN"),          // Delay input (DATAIN, IDATAIN)
       .DELAY_TYPE("VAR_LOAD"),           // Set the type of tap delay line (FIXED, VARIABLE, VAR_LOAD)
       .DELAY_VALUE(0),                // Input delay value setting
       .IS_CLK_INVERTED(1'b0),         // Optional inversion for CLK
       .IS_RST_INVERTED(1'b0),         // Optional inversion for RST
       .REFCLK_FREQUENCY(400.0),       // IDELAYCTRL clock input frequency in MHz (200.0-800.0)
       .SIM_DEVICE("ULTRASCALE_PLUS"), // Set the device version for simulation functionality (ULTRASCALE,
                                      // ULTRASCALE_PLUS, ULTRASCALE_PLUS_ES1, ULTRASCALE_PLUS_ES2)
       .UPDATE_MODE("ASYNC")           // Determines when updates to the delay will take effect (ASYNC, MANUAL,
                                       // SYNC)
    )
    IDELAYE3_inst (
       .CASC_OUT(),       // 1-bit output: Cascade delay output to ODELAY input cascade
       .CNTVALUEOUT(o_cnt_value), // 9-bit output: Counter value output
       .DATAOUT(ref_signal_fine),         // 1-bit output: Delayed data output
       .CASC_IN(1'b0),         // 1-bit input: Cascade delay input from slave ODELAY CASCADE_OUT
       .CASC_RETURN(1'b0), // 1-bit input: Cascade delay returning from slave ODELAY DATAOUT
       .CE(1'b0),                   // 1-bit input: Active-High enable increment/decrement input
       .CLK(ref_clk_400m),                 // 1-bit input: Clock input
       .CNTVALUEIN(i_cnt_value),  // 9-bit input: Counter value input
       .DATAIN(ref_signal),           // 1-bit input: Data input from the logic
       .EN_VTC(1'b1),           // 1-bit input: Keep delay constant over VT
       .IDATAIN(1'b0),     // 1-bit input: Data input from the IOBUF
       .INC(1'b0),                 // 1-bit input: Increment / Decrement tap delay input
       .LOAD(1'b1),               // 1-bit input: Load DELAY_VALUE input
       .RST(reset)                  // 1-bit input: Asynchronous Reset to the DELAY_VALUE
    );

    // End of IDELAYE3_inst instantiation
endmodule
