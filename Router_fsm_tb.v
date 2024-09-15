module router_fsm_tb;

 // Inputs
 reg clock;
 reg resetn;
 reg pkt_valid;
 reg [1:0] data_in;
 reg fifo_full;
 reg fifo_empty_0;
 reg fifo_empty_1;
 reg fifo_empty_2;
 reg soft_reset_0;
 reg soft_reset_1;
 reg soft_reset_2;
 reg parity_done;
 reg low_packet_valid;

 // Outputs
 wire write_enb_reg;
 wire detect_add;
 wire ld_state;
 wire laf_state;
 wire lfd_state;
 wire full_state;
 wire rst_int_reg;
 wire busy;
 
 parameter cycle=10;

 // Instantiate the Unit Under Test (UUT)
 router_fsm uut (
  .clock(clock), 
  .resetn(resetn), 
  .pkt_valid(pkt_valid), 
  .data_in(data_in), 
  .fifo_full(fifo_full), 
  .fifo_empty_0(fifo_empty_0), 
  .fifo_empty_1(fifo_empty_1), 
  .fifo_empty_2(fifo_empty_2), 
  .soft_reset_0(soft_reset_0), 
  .soft_reset_1(soft_reset_1), 
  .soft_reset_2(soft_reset_2), 
  .parity_done(parity_done), 
  .low_packet_valid(low_packet_valid), 
  .write_enb_reg(write_enb_reg), 
  .detect_add(detect_add), 
  .ld_state(ld_state), 
  .laf_state(laf_state), 
  .lfd_state(lfd_state), 
  .full_state(full_state), 
  .rst_int_reg(rst_int_reg), 
  .busy(busy)
 );
  
   initial
   begin
    clock=1'b1;
    forever #cycle clock = ~clock;
   end

   task initialize;
   begin
   {pkt_valid,fifo_empty_0,fifo_empty_1,fifo_empty_2,fifo_full,parity_done,low_packet_valid}=0;
   end
   endtask

   task rst;
   begin
   @(negedge clock)
    resetn=1'b0;
   @(negedge clock)
    resetn=1'b1;
   end
   endtask

   task t1;
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end              
   @(negedge clock) //LD
   @(negedge clock) //LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask

   task t2;
   begin
   @(negedge clock)//LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=1;
   fifo_empty_0<=1;
   end
   @(negedge clock)//LD
   @(negedge clock)//FFS
   fifo_full<=1;
   @(negedge clock)//LAF
   fifo_full<=0;
   @(negedge clock)//LP
   begin
   parity_done<=0;
   low_packet_valid<=1;
   end
   @(negedge clock)//CPE
   @(negedge clock)//DA
   fifo_full<=0;
   end
   endtask

   task t3;
   begin
   @(negedge clock) //LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=2;
   fifo_empty_0<=1;
   end
   @(negedge clock) //LD
   @(negedge clock) // FFS
   fifo_full<=1;
   @(negedge clock) // LAF
   fifo_full<=0;
   @(negedge clock)  // LD
   begin
      low_packet_valid<=0;
 parity_done<=0;

   end  // LP
   @(negedge clock)
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock) // CPE
   @(negedge clock) // DA
   fifo_full<=0;
   end
   endtask
   
   task t4;
   begin
   @(negedge clock)  // LFD
   begin
   pkt_valid<=1;
   data_in[1:0]<=0;
   fifo_empty_0<=1;
   end        
   @(negedge clock)   // LD
   @(negedge clock)   // LP
   begin
   fifo_full<=0;
   pkt_valid<=0;
   end
   @(negedge clock)   // CPE 
   @(negedge clock)   // FFS
   fifo_full<=1;
   @(negedge clock)   // LAF
   fifo_full<=0;
  @(negedge clock)    // DA
   parity_done=1;
   end
   endtask


   initial
   begin
   rst;
   initialize;
  
    t1;
 rst;
 #30
    t2;
 rst;
 #30
 t3;
 rst;
 #30
    t4;
 rst;
      //#1000 $finish;
   end

    
endmodule
