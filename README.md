# NCO - Numerically Controlled Oscillator in VHDL

A **Numerically Controlled Oscillator (NCO)** is a digital signal processing component used to generate periodic waveforms, typically sine or cosine waves, with precise control over frequency and phase. It is commonly used in communication systems, such as modulators and demodulators, signal synthesis, and software-defined radios, where accurate frequency generation and signal processing are critical.

This is a synthesizable VHDL implementation of an NCO that can be used in FPGAs, CPLDs, or even ASICs. It’s worth noting that this NCO is an extremely simple circuit to implement 

> **FUN FACT:** Creating this Markdown file turned out to be much more challenging than writing the VHDL code itself!

### DDS - Direct digital syntheses 

The NCO works in the digital domain. Its output is just a bunch os bits that represent a sine wave. In order to convert these digital amplitude values into an analog signal, a Digital-to-Analog Converter (DAC) is used. The combination of the NCO with a DAC forms the basis of a Direct Digital Synthesis (DDS) system, which is widely used in signal generators, communication systems, and other applications requiring precise frequency and phase control. 

### Architecture

A hardware implementation of a NCO is, at its core, a remarkably straightforward circuit with two primary components: a phase accumulator and a sine lookup table. The phase accumulator is essentially a counter that increments its value with each clock cycle, representing the phase of the waveform being generated. The sine lookup table, on the other hand, contains precomputed values of a sine wave corresponding to different phases. So the output of the phase acumulator is directect connect to the sine lookup table. For every phase input, there is a precomputed value of a sine wave on the output.Together, these components allow the NCO to generate precise sine wave outputs. 

![Basic NCO Architecture](./doc/images/NCO_basic_architecture.png?raw=true)

The input to the circuit is the Frequency Control Word (FCW), which determines how much the phase accumulator (referred to as phase_acc) is incremented with each clock cycle. Essentially, the FCW controls the frequency of the output signal. The larger the FCW, the faster the phase_acc counts, which results in a higher frequency for the output waveform generated by the NCO. 

![NCO fcw vs phase accumulator](./doc/images/NCO_fcw_vs_phase_acc.png?raw=true)

The image above illustrates how the phase_acc increments for two different FCW values (1 and 2). As shown, when the FCW is set to 2, the phase_acc increases twice as fast compared to when the FCW is 1. This demonstrates how a higher FCW results in a faster progression of the phase, leading to a higher frequency output.

It also reveals the sawtooth pattern of the phase_acc output. This sawtooth shape occurs because the phase_acc continuously increments until it reaches its maximum value, then wraps around to zero and starts incrementing again. It should be noted that this sawtooth waveform represents the phase of a sine wave in digital form. As the phase_acc linearly progresses from 0 to its maximum value, it effectively maps out the entire cycle of the sine wave. When the phase_acc wraps around to zero, it signifies the completion of one full cycle of the sine wave and the beginning of the next. The gradual increase in the phase_acc corresponds to the smooth progression through the sine wave's phase, while the abrupt reset at the maximum value correlates to the transition back to the start of the sine wave cycle.

It's fascinating that such a simple combination — a counter and a table — can form the basis of a highly versatile and powerful signal generator.


### Synthesizable

Not all VHDL code can be synthesized and implemented in hardware. The code in this project is synthesizable and has been tested with Altera (Intel) synthesis tools. While the design offers high performance, it should be adjusted for specific device implementations to optimize both performance and resource utilization.

One crucial aspect for achieving better performance and efficient resource usage is the sine/cosine look-up table (LUT). This LUT contains precomputed sine values, functioning essentially as a read-only memory (ROM). FPGAs offer multiple ways to implement these tables: they can be created using distributed small LUTs within standard cells or by utilizing dedicated memory blocks (such as BRAM, M9K, etc.). The choice between these methods can significantly impact both the speed and resource efficiency of your design.

Another key factor in synthesis optimization is the pipeline depth. Since the NCO is a synchronous design, information moves through the pipeline within each clock cycle, passing from one register to the next. The depth, width, and the amount of logic between these registers have a profound impact on the final device clock speed. The code follows best practices, such as placing registers after most logic operations and using synchronous LUTs (with a register placed after them). These strategies help to maintain high speed and stability in the synthesized design.


## VHDL Code - NCO Core

The nco (Numerically Controlled Oscillator) entity is designed with flexible parameters and input/output ports to generate a sine wave signal based on a given frequency control word (FCW).

### Core  Parameters

The generic parameters allow customization of the phase width, multiplier width, and sine output width, determining the final bit width of each component. These **generic** parameters enable the design to be adapted for various precision and resource requirements. It should be noted that these parameters must be defined before synthesis and cannot be changed during hardware utilization.


| Name            | Description                                             | Type    | Default Value |
|-----------------|---------------------------------------------------------|---------|---------------|
| `C_PHASE_WIDTH` | Defines the bit width of the phase accumulator and phase counter. | integer | 8             |
| `C_MULT_WIDTH`  | Defines the bit width of the amplitude control word (ACW).        | integer | 2             |
| `C_SINE_WIDTH`  | Defines the bit width of the sine wave output.                    | integer | 16            |

* The sine wave table width is automatically calculated based on the formula `C_SINE_WIDTH - C_MULT_WIDTH`. The deault value is 14 bits.

### Port Signals

The port signals provide the necessary inputs for resetting, clocking, enabling the circuit, and setting the frequency and phase control words, as well as the amplitude control word (ACW), and output the generated sine wave.

| Name    | Direction | Description                                                    | Type         | Signal Width                                   |
|---------|-----------|----------------------------------------------------------------|--------------|------------------------------------------------|
| `rst`   | in        | Reset signal, active low, used to initialize the NCO.          | `std_logic`  | 1                                              |
| `clk`   | in        | Clock signal, drives the operation of the NCO.                 | `std_logic`  | 1                                              |
| `enable`| in        | Enable signal, when high, the NCO operates; otherwise, it is idle. | `std_logic`  | 1                                              |
| `fcw`   | in        | Frequency Control Word, determines the increment value of the phase accumulator. | `std_logic_vector` | `C_PHASE_WIDTH`                                |
| `pcw`   | in        | Phase Control Word, used to set the phase offset.              | `std_logic_vector` | `C_PHASE_WIDTH`                                |
| `acw`   | in        | Amplitude Control Word, scales the amplitude of the sine wave output. | `std_logic_vector` | `C_MULT_WIDTH`                                 |
| `sine`  | out       | The generated sine wave output.                                | `std_logic_vector` | `C_SINE_WIDTH`                                 |


## Sine Output Frequency


### Phase Resolution Formula

The phase resolution defines the smallest possible change in phase that the NCO can resolve, determined by the bit width of the phase accumulator (`C_PHASE_WIDTH`). This resolution is independent of the FCW or the clock frequency, and represents the smallest phase step that can be taken by the phase accumulator, directly affecting the granularity of the phase increments. This parameter must be defined in the design phase, before synthesis. 

It should be noted that increasing the resolution impacts the minimum frequency (and also the quantization error). For example, a `C_PHASE_WIDTH` of 32 bits will provide a very fine phase resolution but will also result in a very low minimum frequency (as shown in the table below).

```math
f_{res} = \frac{360°}{2^{C\_PHASE\_WIDTH}}
```


Where:
- `C_PHASE_WIDTH` is the bit width of the phase accumulator.
- `f_{res}` is the phase resolution in degrees, representing the smallest frequency step that can be achieved.

Example Values for Phase Width and Corresponding Resolution.  For example, enven though 32 bits provides a very fine resolution for the phase, the frequency for fcw=1 is less than a hertz. 

| Phase Width (`C_PHASE_WIDTH`) | Phase Resolution (Degrees) | Output Frequency for `FCW = 1` and `fclk = 200MHz` |
|-------------------------------|----------------------------|----------------------------------------------------------|
| 2 bits                        | 90°                        | 50 MHz                                                   |
| 4 bits                        | 22.5°                      | 12.5 MHz                                                 |
| 8 bits                        | 1.41°                      | 781.25 kHz                                               |
| 10 bits                       | 0.35°                      | 195.3125 kHz                                             |
| 12 bits                       | 0.088°                     | 48.828125 kHz                                            |
| 14 bits                       | 0.022°                     | 12.20703125 kHz                                          |
| 16 bits                       | 0.0055°                    | 3.0517578125 kHz                                         |
| 20 bits                       | 0.00034°                   | 190.73486328125 Hz                                       |
| 24 bits                       | 0.000021°                  | 11.920928955078125 Hz                                    |
| 32 bits                       | 0.000000084°               | 0.04656612873077392578 Hz                                |

### Frequency Calculation Formula

The output frequency of the NCO is determined by the Frequency Control Word (FCW), the clock frequency, and the bit width of the phase accumulator (`C_PHASE_WIDTH`). It indicates the actual frequency of the sine wave generated by the NCO.

```math
f_{out} = {FCW} \times \frac{f_{clk}}{2^{C\_PHASE\_WIDTH}}
```

Where:
- `C_PHASE_WIDTH` is the bit width of the phase accumulator.
- `f_{clk}` is the clock frequency driving the NCO.
- `f_{out}` is the output frequency of the sine wave.
- `FCW` is the Frequency Control Word.

### Example Calculation

Below are examples of how the output frequency is determined by the values of `fcw` and `C_PHASE_WIDTH`. The `fcw` is defined during hardware operation, while `C_PHASE_WIDTH` is set during synthesis and cannot be changed during hardware utilization. The `C_PHASE_WIDTH` determines the resolution of the phase accumulator, and consequently, defines the phase resolution of the hardware. A larger `C_PHASE_WIDTH` provides finer frequency resolution but requires more hardware resources. In these examples, `C_PHASE_WIDTH` is set to 10 bits.

### Example 1

Parameters set and defined before synthesis:

| Parameter                | Generic   | Value       |
|--------------------------|------------------|-------------|
| Phase Width              | `C_PHASE_WIDTH`   | 10 bits     |
| Phase Resolution         | -                | 0.351°   |


Parameters set and dynamically defined during hardware utilization:

| Parameter                | Signal   | Value       |
|--------------------------|------------------|-------------|
| Clock Frequency          | `clk`            | 200 MHz     |
| Frequency Control Word   | `fcw`            | 1           |
| Output Frequency         | -                | 195.31 kHz  |


| Parameter                | Signal   | Value       |
|--------------------------|------------------|-------------|
| Clock Frequency          | `clk`            | 200 MHz     |
| Frequency Control Word   | `fcw`            | 8           |
| Output Frequency         | -                | 1.5625 MHz  |


### Example 2

## License


## Runnig the simulation 

![GTKWave with NCO simulation](https://github.com/portela/NCO/blob/develop/doc/images/GTKWave_with_NCO_simulation_using_GHDL.png?raw=true)

Analyze, run the simulation, and open GTKWave with the simulation data:
```console
$ mkdir work
$ ghdl -a --workdir=work src/nco/sine_lut.vhd src/nco/nco.vhd src/nco/nco_tb01.vhd
$ ghdl -r --workdir=work nco_tb01  --wave=work/nco_tb01.ghw
$ gtkwave work/nco_tb01.ghw
```

You also have the option to open the saved simulation view
```console
$ gtkwave wave/nco_tb01.gtkw
```

## Development Environment

One of the reasons I created this project was to explore the use of open-source tools as the primary development environment, aiming to reduce reliance on commercial tools. While the open-source tools provide a robust environment for design and simulation, proprietary tools are still necessary for synthesizing the code for an FPGA and programming the device. 

I will also be using this code to experiment with DSP on FPGAs, including designing fully digital PLLs, Costa Loops, and transceivers (ASK, FSK, BPSK, QPSK, QAM), among other applications.

### Environment and tools

My development environment is based on Linux, but I'm using Windows 10 with WSL. Configuring and installing WSL is beyond the scope of this document. Here is a list of tools that I use:

* **GHDL**: A VHDL simulator that allows you to analyze, elaborate, and simulate VHDL designs. 

* **GTKWave**: A waveform viewer used to visualize simulation results generated by tools like GHDL. After running a simulation, GTKWave allows you to inspect the signals and verify the behavior of your design over time.

* **Make**: A build automation tool that automatically builds executable programs and libraries from source code. In this context, `Make` is used to manage the process of compiling VHDL files and running simulations. It simplifies complex build processes by automating tasks and handling dependencies.

* **VS Code**: Visual Studio Code is a source-code editor that supports development operations like debugging, task running, and version control. 

* **VHDL for Professionals** (VS Code) extension enhances VS Code with features like syntax highlighting, code snippets, and linting specific to VHDL, making it easier to write and manage VHDL code.

* **Git**: A version control system used for tracking changes in source code during software development. Git allows you to manage your codebase, collaborate with others, and keep a history of all changes made to your VHDL projects.


### Installing the tools

Install basic tools:
```console
$ sudo apt-get install ghdl gtkwave
$ sudo apt-get -y install make
```

### ToDo

- [X] Docs: phase resolution and frequency formula
- [X] Docs: two examples of phase and frequency calculation
- [ ] Docs: talk about pcw
- [ ] Docs: talk about acw
- [ ] Docs: final architecture
- [ ] Docs: simulation picture for multiple cases
- [ ] Docs: make a simple AM, FM, ASK, FSK, BPSK modulator 
- [ ] Docs: quantization error
- [ ] Improve Makefile
- [ ] Add cosine output
- [ ] Make a simple modulator (FSK? BPSK?)

# About me

I am H. Portela, an engineer with a passion for high-performance electronics design, including RF, microwave, DSP, and digital electronics engineering. To learn more about my projects, follow me on [LinkedIn](https://www.linkedin.com/in/henriqueportela/).