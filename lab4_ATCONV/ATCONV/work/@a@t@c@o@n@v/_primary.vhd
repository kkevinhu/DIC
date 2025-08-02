library verilog;
use verilog.vl_types.all;
entity ATCONV is
    generic(
        READ            : integer := 0;
        layer0_RD       : integer := 1;
        layer0_WR       : integer := 2;
        \DONE\          : integer := 3
    );
    port(
        clk             : in     vl_logic;
        rst             : in     vl_logic;
        ROM_rd          : out    vl_logic;
        iaddr           : out    vl_logic_vector(11 downto 0);
        idata           : in     vl_logic_vector(15 downto 0);
        layer0_ceb      : out    vl_logic;
        layer0_web      : out    vl_logic;
        layer0_A        : out    vl_logic_vector(11 downto 0);
        layer0_D        : out    vl_logic_vector(15 downto 0);
        layer0_Q        : in     vl_logic_vector(15 downto 0);
        layer1_ceb      : out    vl_logic;
        layer1_web      : out    vl_logic;
        layer1_A        : out    vl_logic_vector(11 downto 0);
        layer1_D        : out    vl_logic_vector(15 downto 0);
        layer1_Q        : in     vl_logic_vector(15 downto 0);
        done            : out    vl_logic
    );
    attribute mti_svvh_generic_type : integer;
    attribute mti_svvh_generic_type of READ : constant is 1;
    attribute mti_svvh_generic_type of layer0_RD : constant is 1;
    attribute mti_svvh_generic_type of layer0_WR : constant is 1;
    attribute mti_svvh_generic_type of \DONE\ : constant is 1;
end ATCONV;
