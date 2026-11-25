module wr_pointer #(parameter ADDR_WIDTH = 5)
(
	input wire wclk,
	input wire wrst_n, 
	input wire w_en,
	input wire [ADDR_WIDTH-1:0] rgray_sync, //this signal comes from read_pointer handler
	output reg [ADDR_WIDTH-1:0] wbin,
	output reg [ADDR_WIDTH-1:0] wgray, 
	output reg wfull
);

wire [ADDR_WIDTH-1:0] wbin_next;
wire [ADDR_WIDTH-1:0] wgray_next;

wire winc;

assign winc = w_en && !wfull;

assign wbin_next = wbin + winc;

assign wgray_next = wbin_next ^ (wbin_next>>1);

always @(posedge wclk or negedge wrst_n)
begin
if(!wrst_n)
begin
wbin <= 0;
wgray <= 0;
wfull <= 1'b0;
end
else
begin
wbin <= wbin_next;
wgray <= wgray_next;
wfull <= ({~rgray_sync[ADDR_WIDTH-1:ADDR_WIDTH-2],rgray_sync[ADDR_WIDTH-3:0]} == wgray_next);
end
end
endmodule
