f303_sdr
========

Experimental project to try out some SDR ideas on an STM32F303

<edit> Basically looks like a dead end. While it's possible to run the F303 ADC at up to ~5MHz,
the 72MHz Cortex M4F processor doesn't have the cycles to run a long enough integrator to give
good out-of-band rejection on the front-end tuning/filtering/decimation operation.
