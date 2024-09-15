module router_fifo(
    input clock,resetn,write_en,soft_reset,read_en,lfd_state,
    input [7:0] data_in,
    output reg[7:0] data_out,
    output empty,full
    );
  reg[8:0] mem[0:15];
  reg[4:0] wr_ptr,rd_ptr;
  reg [6:0]fifo_count;
  reg lfd_state_s;
  integer i;
  
  //To delay lfd_state by 1 clock cycle
  
  always@(posedge clock)
     begin
     if(!resetn)
      lfd_state_s<=0;
   else
    lfd_state_s<=lfd_state;
   end
 
 //To increment the pointers
 
  always@(posedge clock)
     begin
     if(!resetn)
     {rd_ptr,wr_ptr}<=0;
     else if(soft_reset)
      {rd_ptr,wr_ptr}<=0;
   else
     begin
       if(write_en && !full)
        wr_ptr<=wr_ptr+1;
     else
        wr_ptr<=wr_ptr;
    
     if(read_en && !empty)
       rd_ptr<=rd_ptr+1;
     else
       rd_ptr<=rd_ptr;
    end
   end
   
    
  // FIFO down counting
  
  always@(posedge clock)
    begin
     if(!resetn)
     fifo_count<=0;
   else if(soft_reset)
     fifo_count<=0;
   else if(read_en && !empty)
     begin
        if(mem[rd_ptr[3:0]][8]==1)
        fifo_count<=mem[rd_ptr[3:0]][7:2]+ 1'b1;
      else if(fifo_count!=0)
        fifo_count<=fifo_count - 1'b1;
    end
  end
  
 //write_operation
 
  always@(posedge clock)
    begin
    if(!resetn)begin
      for(i=0;i<16;i=i+1)
      mem[i]<=0;
   end
   
    else if(soft_reset) begin
      for(i=0;i<16;i=i+1)
      mem[i]<=0;
   end
   
    else if(write_en && !full)
      begin 
      if(lfd_state_s)
     begin
           mem[wr_ptr[3:0]][8]<=1'b1;
     mem[wr_ptr[3:0]][7:0]<=data_in;
  end
  
  else
     begin
      mem[wr_ptr[3:0]][8]<=1'b0;
      mem[wr_ptr[3:0]][7:0]<=data_in;
    
      end
  end
  end
 // Read operation
  
  always@(posedge clock)
    begin
    if(!resetn)
      data_out<=0;
   
    else if(soft_reset) 
      data_out<=0;
    
    else if(read_en && !empty)
            data_out <=mem[rd_ptr[3:0]][7:0]; 
   
    else if(fifo_count ==0 && data_out!=0)
       data_out<=8'bz;
    
    
  
 end
 
 assign full=(wr_ptr =={~rd_ptr[4],rd_ptr[3:0]});
 assign empty=(rd_ptr==wr_ptr);
  
endmodule
