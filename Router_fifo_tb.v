module Router_fifo_tb;

 // Inputs
 reg clock;
 reg resetn;
 reg write_en;
 reg soft_reset;
 reg read_en;
 reg lfd_state;
 reg [7:0] data_in;

 // Outputs
 wire [7:0] data_out;
 wire empty;
 wire full;
 
 reg[7:0] header,parity;
 reg[1:0] addr;
 integer i;
 
 initial begin
   clock=0;
   forever
     #10 clock=~clock;
   end
  

 // Instantiate the Unit Under Test (UUT)
 router_fifo uut (
  .clock(clock), 
  .resetn(resetn), 
  .write_en(write_en), 
  .soft_reset(soft_reset), 
  .read_en(read_en), 
  .lfd_state(lfd_state), 
  .data_in(data_in), 
  .data_out(data_out), 
  .empty(empty), 
  .full(full)
 );
 
 task reset();
 begin
   @(negedge clock)
    resetn=1'b0;
   @(negedge clock)
    resetn=1'b1;
 end
 endtask
 
 task soft_rst();
   begin
     @(negedge clock)
       soft_reset=1'b1;
     @(negedge clock)
       soft_reset=1'b0;
    end
 endtask
 
 task initialize();
   begin
     write_en=1'b0;
   soft_reset=1'b0;
   read_en=1'b0;
   data_in=0;
   lfd_state=1'b0;
  end
 endtask
 
 task write;
    reg[7:0] payload_data;
  reg [5:0]payload_len;
  begin
    @(negedge clock);
      payload_len=6'd14;
    addr=2'b01;
    header={payload_len,addr};
    data_in=header;
    lfd_state=1'b1;
    write_en=1;
    
    for(i=0;i<payload_len;i=i+1)
      begin
      @(negedge clock);
        lfd_state=0;
      payload_data={$random}%256;
      data_in=payload_data;
    end
   
   @(negedge clock);
   
   parity={$random}%256;
   data_in=parity;
   end
  endtask
  
  
   

 initial begin
  // Initialize Inputs
  initialize();
  reset();
  reset();
  soft_rst;
  write;
  
  repeat(2)
   @(negedge clock);
     read_en = 1;
   write_en=0;
  
 
   
  @(negedge clock);
   wait(empty)
    @(negedge clock)
      read_en=0;
    
    
  //#100 $finish;
  

 

 end
      
endmodule
