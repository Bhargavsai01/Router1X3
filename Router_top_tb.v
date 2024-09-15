module Router_top_tb;

 // Inputs
 reg clock;
 reg resetn;
 reg pkt_valid;
 reg read_enb_0;
 reg read_enb_1;
 reg read_enb_2;
 reg [7:0] data_in;

 // Outputs
 wire busy;
 wire err;
 wire vld_out_0;
 wire vld_out_1;
 wire vld_out_2;
 wire [7:0] data_out_0;
 wire [7:0] data_out_1;
 wire [7:0] data_out_2;
integer i;
 // Instantiate the Unit Under Test (UUT)
 router_top uut (
  .clock(clock), 
  .resetn(resetn), 
  .pkt_valid(pkt_valid), 
  .read_enb_0(read_enb_0), 
  .read_enb_1(read_enb_1), 
  .read_enb_2(read_enb_2), 
  .data_in(data_in), 
  .busy(busy), 
  .err(err), 
  .vld_out_0(vld_out_0), 
  .vld_out_1(vld_out_1), 
  .vld_out_2(vld_out_2), 
  .data_out_0(data_out_0), 
  .data_out_1(data_out_1), 
  .data_out_2(data_out_2)
 );

 initial 
 begin
 clock = 1;
 forever 
 #5 clock=~clock;
 end
 
 
 task reset;
  begin
      @(negedge clock)
   resetn=1'b0;
   @(negedge clock)
   resetn=1'b1;
  end
 endtask
 
 task initialize;
     begin
     resetn = 1'b1;
     {read_enb_0, read_enb_1, read_enb_2, pkt_valid}=0;
  end
    endtask
  
 
 task pktm_gen_5; // packet generation payload 5
   reg [7:0]header, payload_data, parity;
   reg [8:0]payloadlen;
   
   begin
    parity=0;
    wait(!busy)
    begin
    @(negedge clock);
    payloadlen=5;
    pkt_valid=1'b1;
    header={payloadlen,2'b10};
    data_in=header;
    parity=parity^data_in;
    end
    @(negedge clock);
       
    for(i=0;i<payloadlen;i=i+1)
     begin
     wait(!busy)
                    begin  
     @(negedge clock);
     payload_data={$random}%256;
     data_in=payload_data;
     parity=parity^data_in;
                    end  
     end     
        
              wait(!busy)
                    begin
     @(negedge clock);
     pkt_valid=0;    
     data_in=parity;
                    end  
              repeat(2)
   @(negedge clock);
   read_enb_2=1'b1;
              
         
           @(negedge clock)
          #70 read_enb_2=0;  
   end
      
endtask
 
 task pktm_gen_14; // packet generation payload 14
   reg [7:0]header, payload_data, parity;
   reg [8:0]payloadlen;
   
   begin
    parity=0;
    wait(!busy)
    begin
    @(negedge clock);
    payloadlen=14;
    pkt_valid=1'b1;
    header={payloadlen,2'b01};
    data_in=header;
    parity=parity^data_in;
    end
    @(negedge clock);
       
    for(i=0;i<payloadlen;i=i+1)
     begin
     wait(!busy)
                    begin  
     @(negedge clock);
     payload_data={$random}%256;
     data_in=payload_data;
     parity=parity^data_in;
                    end  
     end     
        
              wait(!busy)
                    begin
     @(negedge clock);
     pkt_valid=0;    
     data_in=parity;
                    end  
              repeat(2)
   @(negedge clock);
    read_enb_1=1'b1;
              
              
           @(negedge clock)
           #70 read_enb_1=0;  
   end
endtask

 task pktm_gen_16; // packet generation payload 16
   reg [7:0]header, payload_data, parity;
   reg [8:0]payloadlen;
   
   begin
    parity=0;
    wait(!busy)
    begin
    @(negedge clock);
    payloadlen=16;
    pkt_valid=1'b1;
    header={payloadlen,2'b00};
    data_in=header;
    parity=parity^data_in;
    end
    @(negedge clock);
       
    for(i=0;i<payloadlen;i=i+1)
     begin
     wait(!busy)
                    begin  
     @(negedge clock);
     payload_data={$random}%256;
     data_in=payload_data;
     parity=parity^data_in;
                    end  
     end     
        
              wait(!busy)
                    begin
     @(negedge clock);
     pkt_valid=0;    
     data_in=parity;
                    end  
              repeat(2)
   @(negedge clock);
   read_enb_0=1'b1;
              
             
           @(negedge clock)
           #100 read_enb_0=0;  
   end
endtask


 
 initial
  begin
      initialize;
   reset;
   #10;
   pktm_gen_5;
            #100;
            //reset;
   pktm_gen_14;
   #100;
   pktm_gen_16;
   #700;
   //$finish;
  end
      
endmodule
