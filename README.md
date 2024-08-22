# NCO - Numerically Controlled Oscillator in VHDL

A **Numerically Controlled Oscillator (NCO)** is a digital signal processing component used to generate periodic waveforms, typically sine or cosine waves, with precise control over frequency and phase. It is commonly used in communication systems, such as modulators and demodulators, signal synthesis, and software-defined radios, where accurate frequency generation and signal processing are critical.

This is a synthesizable VHDL implementation of an NCO that can be used in FPGAs, CPLDs or even ASICs. I will be using this in fully digital PLL, Costa Loop, and transceivers (ASK, FSK, BPSK, QPSK, QAM).

### DDS - Direct digital syntheses 

The NCO works in the digital domain. Its output is just a bunch os bits that represent a sine wave. In order to convert these digital amplitude values into an analog signal, a Digital-to-Analog Converter (DAC) is used. The combination of the NCO with a DAC forms the basis of a Direct Digital Synthesis (DDS) system, which is widely used in signal generators, communication systems, and other applications requiring precise frequency and phase control. Together, these components enable the NCO to generate precise sine wave outputs.

### Architecture

A hardware implementation of a NCO is, at its core, a remarkably straightforward circuit with two primary components: a phase accumulator and a sine lookup table. The phase accumulator is essentially a counter that increments its value with each clock cycle, representing the phase of the waveform being generated. The sine lookup table, on the other hand, contains precomputed values of a sine wave corresponding to different phases. So the output of the phase acumulator is directect connect to the sine lookup table. For every phase input, there is a precomputed value of a sine wave on the output.Together, these components allow the NCO to generate precise sine wave outputs. 

It's fascinating that such a simple combination — a counter and a table — can form the basis of a highly versatile and powerful signal generator.

### Synthesizable

Not all VHDL code can be synthesized and implemented in hardware. The code in this project is synthesizable and has been tested with Altera (Intel) and Xilinx (AMD) synthesis tools. While the design offers high performance, it should be adjusted for specific device implementations to optimize both performance and resource utilization.

One crucial aspect for achieving better performance and efficient resource usage is the sine/cosine look-up table (LUT). This LUT contains precomputed sine values, functioning essentially as a read-only memory (ROM). FPGAs offer multiple ways to implement these tables: they can be created using distributed small LUTs within standard cells or by utilizing dedicated memory blocks (such as BRAM, M9K, etc.). The choice between these methods can significantly impact both the speed and resource efficiency of your design.

Another key factor in synthesis optimization is the pipeline depth. Since the NCO is a synchronous design, information moves through the pipeline within each clock cycle, passing from one register to the next. The depth, width, and the amount of logic between these registers have a profound impact on the final device clock speed. The code follows best practices, such as placing registers after most logic operations and using synchronous LUTs (with a register placed after them). These strategies help to maintain high speed and stability in the synthesized design.


## License


## Runnig the simulation 

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


# About me

I am H. Portela, an engineer with a passion for high-performance electronics design, including RF, microwave, DSP, and digital electronics engineering. To learn more about my projects, follow me on [LinkedIn](https://www.linkedin.com/in/henriqueportela/).