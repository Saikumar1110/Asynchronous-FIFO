module asynchronous_fifo_tb ();
parameter DATA_WIDTH = 8;
parameter ADDR_WIDTH = 5;
parameter DEPTH = 16;

// DUT inputs
reg wclk = 0;
reg rclk = 0;

reg wrst_n;
reg rrst_n;

reg r_en;
reg w_en;

reg [DATA_WIDTH-1:0] wdata;



//DUT Outputs
wire [DATA_WIDTH-1:0] rdata;
wire full;
wire empty;


asynchronous_fifo_top #(
    .DATA_WIDTH(DATA_WIDTH),
    .ADDR_WIDTH(ADDR_WIDTH),
    .DEPTH(DEPTH)) DUT 
(

    .wclk(wclk),
    .rclk(rclk),

    .wrst_n(wrst_n),
    .rrst_n(rrst_n),

    .w_en(w_en),
    .r_en(r_en),

    .wdata(wdata),
    .rdata (rdata),

    .rempty(rempty),
    .wfull(wfull)
);


always #5 wclk = ~wclk;
always #7 rclk = ~rclk;


initial 
begin

wrst_n = 1'b0;
rrst_n = 1'b0;


w_en = 1'b0;
r_en = 1'b0;

wdata = 8'h00;

$display("TEST 1 : RESET");
#20;

if(wfull == 1'b0)
$display("PASS : FIFO is not full after reset");
else 
$display ("FAIL : FIFO is full after reset");

if(rempty == 1'b1)
$display("PASS : FIFO is empty after reset");
else 
$display ("FAIL : FIFO is not empty after reset");


wrst_n = 1'b1;
rrst_n = 1'b1;

#20;


$display("TEST 2 : Write data");
@(negedge wclk);
w_en = 1'b1;
wdata = 8'hA1;

@(negedge wclk);
wdata = 8'hA2;

@(negedge wclk);
wdata = 8'hA3;

@(negedge wclk);
wdata = 8'hA4;

w_en = 1'b0;


//for synchronization
repeat(3)
        @(posedge rclk);


$display("TEST 3 : read data");
if (rempty == 1'b0)
$display("PASS : FIFO contains data");
else
$display("FAIL : FIFO unexpectedly EMPTY");

@(negedge rclk);
r_en = 1'b1;

@(posedge rclk);
#1;
//reads first value 
$display("Read data = %h", rdata);

//reads second value
@(posedge rclk);
#1;
$display("Read data = %h", rdata);

//reads third value 
@(posedge rclk);
#1;
$display("read data = %h", rdata);


//reads fourth value 
@(posedge rclk);
#1;
$display("read data = %h", rdata);


 @(negedge rclk);
r_en = 1'b0;

//allow empty flag to update 
repeat(3)
@(posedge rclk);


$display("TEST 4 : Empty condition");

if(rempty == 1'b1)
$display("PASS : FIFO is empty");
else
$display("FAIL : FIFO is not empty, it should be");


//lets now try to read when FIFO is empty

@(negedge rclk);
r_en = 1'b1;

@(posedge rclk);
if(rempty == 1'b1)
$display("PASS: Read blocked because FIFO is empty");
else
$display("FAIL: FIFO should remain empty");
@(negedge rclk);
r_en = 1'b0;


$display("TESTE 5 : FILL FIFO");
//lets write all 16 values


repeat(16)
begin
@(negedge wclk);
w_en = 1'b1;
wdata = wdata + 1'b1;
end
@(negedge wclk);
w_en = 1'b0;


@(posedge wclk);
#1;
if(wfull == 1'b1)
$display("PASS : FIFO is Full");
else
$display("FAIL : FIFO should be full");


$display("TEST 6 : write when full");

@(negedge wclk);

w_en = 1'b1;
wdata = 8'hFF;

@(posedge wclk);
if(wfull == 1'b1)
$display("PASS : write blocked because FIFO is FULL");
else
$display("FAIL : FIFO should remain FULL");

@(negedge wclk);
w_en = 1'b0;

$display("TEST 7 : Read FIFO until empty");

repeat(3)
@(posedge rclk);


@(negedge rclk);
r_en = 1'b1;


repeat(16)
begin
@(posedge rclk);
#1;
$display("Read data = %h", rdata);
end

@(negedge rclk);
r_en = 1'b0;




if(rempty == 1'b1)
$display("PASS : FIFO is empty after reading all data");
else
$display("FAIL : FIFO should be empty");



$display("TEST 8 : Pointer wrap around");

@(negedge wclk);

w_en = 1'b1;
wdata = 8'hB1;

@(negedge wclk);
wdata = 8'hB2;

@(negedge wclk);
wdata = 8'hB3;

@(negedge wclk);
wdata = 8'hB4;

w_en = 1'b0;


//allow for synchronization
repeat(3)
@(posedge rclk);

//read new data
@(negedge rclk);
r_en = 1'b1;

repeat(4)
begin
@(posedge rclk);
#1;
$display("Read data = %h", rdata);
end

@(negedge rclk);
r_en = 1'b0;


#50;
$finish;
end

endmodule
