/*
 * ddc.h - digital downconverter function for f303_sdr project
 * just a prototype for an assembly function
 * 01-31-2013 E. Brombaugh
 */

#ifndef __ddc__
#define __ddc__

void ddc(int16_t *idx, uint32_t *lo_ptr, int32_t *si, int32_t *sq);

#endif
