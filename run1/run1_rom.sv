module run1_rom (
	input logic clock,
	input logic [11:0] address,
	output logic [3:0] q
);

logic [3:0] memory [0:2399] /* synthesis ram_init_file = "./run1/run1.mif" */;

always_ff @ (posedge clock) begin
	q <= memory[address];
end

endmodule
