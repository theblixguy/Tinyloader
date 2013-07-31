#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

#define COLOR_BLUE 1
#define COLOR_BLACK 0

size_t t_row;
size_t t_clm;
uint8_t t_clr;
uint16_t* t_bffr;

size_t str_len(const char *s)
{
	int d0;
	size_t res;
	asm volatile("repne\n\t"
		"scasb"
		: "=c" (res), "=&D" (d0)
		: "1" (s), "a" (0), "0" (0xffffffffu)
		: "memory");
	return ~res - 1;
}
 
uint16_t VGA_makeEntry(char clr, uint8_t clr1)
{
	uint16_t c16 = clr;
	uint16_t color16 = clr1;
	return c16 | color16 << 8;
}

void init()
{
	t_row = 0;
	t_clm = 0;
	t_clr = COLOR_BLUE | COLOR_BLACK << 4;
	t_bffr = (uint16_t*) 0xB8000;
	for ( size_t z = 0; z < 24; z++ )
	{
		for ( size_t y = 0; y < 80; y++ )
		{
			const size_t idx = z * 80 + y;
			t_bffr[idx] = VGA_makeEntry(' ', t_clr);
		}
	}
}
void VGA_putEntryAt(char clr, uint8_t clr1, size_t a, size_t b)
{
	const size_t idx = b * 80 + a;
	t_bffr[idx] = VGA_makeEntry(clr, clr1);
}

void VGA_insertChar(char c)
{
	VGA_putEntryAt(c, t_clr, t_clm, t_row);
	if ( ++t_clm == 80 )
	{
		t_clm = 0;
		if ( ++t_row == 24 )
		{
			t_row = 0;
		}
	}
}
void VGA_writeStr(const char* string)
{
	size_t len = str_len(string);
	for ( size_t x = 0; x < len; x++ )
		VGA_insertChar(string[x]);
}
 

extern "C"
void kernel_main()
{
	init();
	VGA_writeStr("Welcome to my tiny kernel. I still have to write code to take user input and perform actions like copy file and more!! :-)\n");
}