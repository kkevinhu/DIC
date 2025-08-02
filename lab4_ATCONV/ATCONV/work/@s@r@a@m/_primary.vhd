library verilog;
use verilog.vl_types.all;
entity SRAM is
    generic(
        Width           : integer := 16;
        Row             : integer := 4096
    );
    port(
        clk             : in     vl_logic;
        SRAM_ceb        : in     vl_logic;
        SRAM_A          : in     vl_logic_vector;
        SRAM_D          : in     vl_logic_vector;
        SRAM_web        : in     vl_logic;
        SRAM_Q          : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Width : constant is 1;
    attribute mti_svvh_generic_type of Row : constant is 1;
end SRAM;
