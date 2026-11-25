module asynchronous_fifo_top #(parameter DATA_WIDTH = 8,
			      parameter ADDR_WIDTH = 5, 
			      parameter DEPTH = 16)
			      
(
	input wire wclk,
	input wire rclk, 
	input wire rrst_n, 
	input wire wrst_n,
	input wire w_en,
	input wire r_en, 
	input wire [DATA_WIDTH-1:0] wdata, 
	output wire [DATA_WIDTH-1:0] rdata, 
	output wire rempty, 
	output wire wfull
);

wire [ADDR_WIDTH-1:0] wbin;
wire [ADDR_WIDTH-1:0] rbin;

wire[ADDR_WIDTH-1:0] wgray;
wire[ADDR_WIDTH-1:0] rgray;

wire[ADDR_WIDTH-1:0] rgray_sync;
wire[ADDR_WIDTH-1:0] wgray_sync;

wire[ADDR_WIDTH-2:0] waddr;
wire[ADDR_WIDTH-2:0] raddr;



assign waddr = wbin[ADDR_WIDTH-2:0];
assign raddr = rbin[ADDR_WIDTH-2:0];







wr_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) wr_pointer_handler 
(
	.wclk(wclk), 
	.wrst_n(wrst_n),
	.w_en(w_en),
	.rgray_sync (rgray_sync), 
	.wbin(wbin), 
	.wgray(wgray), 
	.wfull(wfull)
);


rd_pointer #(.ADDR_WIDTH(ADDR_WIDTH)) rd_pointer_handler 
(
        .rclk       (rclk),
        .rrst_n     (rrst_n),
        .r_en       (r_en),
        .wgray_sync (wgray_sync),
        .rbin       (rbin),
        .rgray      (rgray),
        .rempty     (rempty)
);

synchronizer #(.ADDR_WIDTH(ADDR_WIDTH)) sync_w2r 
(
	.clk(rclk),
	.rst_n(rrst_n),
	.async_in(wgray),
	.sync_out(wgray_sync)
);

synchronizer #(.ADDR_WIDTH(ADDR_WIDTH)) sync_r2w 
(
	.clk(wclk),
	.rst_n(wrst_n),
	.async_in(rgray),
	.sync_out(rgray_sync)
);


fifo_memory #(.DATA_WIDTH(DATA_WIDTH), .ADDRESS_WIDTH(ADDR_WIDTH-1), .DEPTH(DEPTH)) fifo_mem
(
	.wclk  (wclk),
        .w_en  (w_en),
        .wfull (wfull),
        .waddr (waddr),
        .wdata (wdata),
        .raddr (raddr),
        .rdata (rdata)
);

endmodule
