----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04/19/2024 04:49:26 PM
-- Design Name: 
-- Module Name: w_machine - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_unsigned.all;
use IEEE.std_logic_arith.all;

entity WashingMachineController is
    Port (
        clk : in std_logic;
        i_coin : in std_logic;
        i_rinse : in std_logic;
        i_lid : in std_logic;
        o_soak, o_wash, o_rinse, o_spin, o_dry : out std_logic
    );
end WashingMachineController;

architecture Behavioral of WashingMachineController is
    signal count_value : std_logic_vector(35 downto 0) := "111110111100010100100000000000000000"; -- 132*512000000
    type washing_state is (IDLE, soak, wash, rinse, spin, dry);
    signal PS, NS : washing_state;
begin
    process(clk)
    begin
        if rising_edge(clk) then
            PS <= NS;
        end if;
    end process;

    process(clk, count_value)
    begin
        if (i_lid = '0') then -- lid is closed
            if (clk'EVENT and clk = '1') then
                count_value <= count_value - 1;
            end if;
        else -- lid is opened
            count_value <= count_value; -- count_value stays same
        end if;
    end process;

    process(PS, NS, clk)
    begin
        if (i_rinse = '0') then -- no add_rinse state
            case PS is
                when IDLE =>
                    if (i_coin = '1') then
                        NS <= soak;
                    else
                        NS <= PS;
                    end if;
                when soak =>
                    if (count_value = "110010100010110111010000000000000000") then -- (132-26)*512000000 cycles
                        NS <= wash;
                    else
                        NS <= PS;
                    end if;
                when wash =>
                    if (count_value = "100110001001011010000000000000000000") then -- (132-26-26)*512000000 cycles
                        NS <= rinse;
                    else
                        NS <= PS;
                    end if;
                when rinse =>
                    if (count_value = "11001101111111100110000000000000000") then -- (132-26-26-26)*512000000 cycles
                        NS <= spin;
                    else
                        NS <= PS;
                    end if;
                when spin =>
                    if (count_value = "1100110111111110011000000000000000") then -- (132-26-26-26-27)*512000000 cycles
                        NS <= dry;
                    else
                        NS <= PS;
                    end if;
                when dry =>
                    if (count_value = "000000000000000000000000000000") then -- (132-26-26-26-27-27)*512000000 cycles
                        NS <= IDLE;
                    else
                        NS <= PS;
                    end if;
                when others => NS <= IDLE;
            end case;
        else
            case PS is
                when IDLE =>
                    if (i_coin = '1') then
                        NS <= soak;
                    else
                        NS <= PS;
                    end if;
                when soak =>
                    if (count_value = "110100011100111011110000000000000000") then --(132-22)*512000000 cycles
                        NS <= wash;
                    else
                        NS <= PS;
                    end if;
                when wash =>
                    if (count_value = "101001111101100011000000000000000000") then --(132-22-22)*512000000 cycles
                        NS <= rinse;
                    else
                        NS <= PS;
                    end if;
                when rinse =>
                    if (count_value = "10100111110110001100000000000000000") then --(132-22-22-22-22)*512000000 cycles
                        NS <= spin;
                    else
                        NS <= PS;
                    end if;
                when spin =>
                    if (count_value = "1010011111011000110000000000000000") then --(132-22-22-22-22-22)*512000000 cycles
                        NS <= dry;
                    else
                        NS <= PS;
                    end if;
                when dry =>
                    if (count_value = "0000000000000000000000000000000000") then --(132-22-22-22-22-22-22)*512000000 cycles
                        NS <= IDLE;
                    else
                        NS <= PS;
                    end if;
                when others => NS <= IDLE;
            end case;
        end if;
    end process;

end Behavioral;

