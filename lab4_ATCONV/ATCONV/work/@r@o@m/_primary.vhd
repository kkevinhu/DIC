library verilog;
use verilog.vl_types.all;
entity ROM is
    generic(
        Width           : integer := 16;
        Row             : integer := 4096
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ROM_rd          : in     vl_logic;
        ROM_addr        : in     vl_logic_vector;
        ROM_data        : out    vl_logic_vector
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of Width : constant is 1;
    attribute mti_svvh_generic_type of Row : constant is 1;
end ROM;
