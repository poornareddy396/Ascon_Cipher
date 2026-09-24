# ASCON-AEAD128 Hardware Implementation

### Lightweight Authenticated Encryption for FPGA and Embedded Systems

This project presents an RTL implementation of **ASCON-AEAD128**, a lightweight authenticated-encryption algorithm designed for resource-constrained embedded and hardware systems.

The design is developed in **Verilog HDL** and verified using **AMD/Xilinx Vivado simulation and synthesis flows**. The implementation contains the complete encryption/decryption datapath, including initialization, associated-data processing, plaintext/ciphertext processing, finalization, tag generation, and the underlying ASCON permutation.

The current implementation has been functionally verified through RTL simulation for both encryption and decryption. Vivado synthesis has also been performed to obtain an initial hardware resource estimate and identify implementation considerations for FPGA deployment.

---

## Project Status

| Component | Status |
|---|---|
| ASCON permutation | Completed |
| S-box / substitution layer | Completed |
| Linear diffusion layer | Completed |
| Round constant generation | Completed |
| Round counter | Completed |
| Initialization phase | Completed |
| Associated Data processing | Completed |
| Plaintext/Ciphertext processing | Completed |
| Finalization and tag generation | Completed |
| Encryption | **Functionally verified** |
| Decryption | **Functionally verified** |
| Encryption/Decryption consistency | **Verified** |
| RTL testbench | Completed |
| Vivado synthesis | Completed |
| Post-synthesis resource analysis | Completed |
| Timing constraints | Pending |
| Post-implementation timing analysis | Pending |
| FPGA pin constraints | Pending |
| Bitstream generation | Pending |
| Physical FPGA validation | Pending |
| Hardware performance characterization | Pending |

---

# 1. Motivation

Modern embedded systems increasingly require secure communication while operating under strict constraints on:

- silicon area,
- power consumption,
- memory,
- latency,
- throughput,
- and hardware complexity.

Conventional cryptographic implementations can introduce significant computational and architectural overhead in such systems.

ASCON is a lightweight authenticated-encryption algorithm designed for environments where implementation efficiency is important. In addition to confidentiality, authenticated encryption provides integrity and authenticity of the protected data.

This project explores the implementation of ASCON-AEAD128 directly at the RTL level, with particular emphasis on:

- hardware-oriented datapath design,
- modular Verilog implementation,
- sequential control of permutation rounds,
- authenticated-encryption data flow,
- FPGA synthesis,
- resource utilization,
- and eventual hardware deployment.

The implementation is intended as a foundation for secure communication hardware in embedded and real-time systems.

---

# 2. ASCON Hardware Architecture

The core ASCON state is represented as a **320-bit state**, divided into five 64-bit words:

```text
                 ASCON 320-bit State
        +-----------------------------------+
        | X0 | X1 | X2 | X3 | X4 |
        +-----------------------------------+
             64   64   64   64   64
```

The ASCON permutation operates on this 320-bit state through repeated rounds consisting of:

1. Addition of a round constant
2. Nonlinear substitution layer
3. Linear diffusion layer

Conceptually:

```text
             320-bit State
                   |
                   v
        +----------------------+
        | Round Constant       |
        | Addition             |
        +----------------------+
                   |
                   v
        +----------------------+
        | Nonlinear S-Box      |
        | Substitution         |
        +----------------------+
                   |
                   v
        +----------------------+
        | Linear Diffusion     |
        +----------------------+
                   |
                   v
             Next State
```

---

# 3. Top-Level Encryption/Decryption Architecture

The complete cryptographic operation is controlled by the top-level RTL module.

The high-level processing flow is:

```text
                        START
                          |
                          v
                +------------------+
                | Initialization   |
                +------------------+
                          |
                          v
                +------------------+
                | Associated Data  |
                | Processing       |
                +------------------+
                          |
                          v
                +------------------+
                | PT / CT          |
                | Processing       |
                +------------------+
                          |
                          v
                +------------------+
                | Finalization     |
                | + Tag Generation |
                +------------------+
                          |
                          v
                        DONE
```

The current controller uses the following conceptual states:

```text
IDLE
  |
  v
INIT
  |
  v
AD
  |
  v
PT/CT
  |
  v
FINAL
  |
  v
DONE
  |
  v
IDLE
```

Each processing module provides a handshake signal indicating completion of its operation. The next stage is then activated by the top-level controller.

This approach keeps the individual cryptographic stages modular and allows the permutation datapath to be developed and verified independently.

---

# 4. RTL Module Organization

The implementation is divided into functional RTL blocks.

| Module | Function |
|---|---|
| `TOP.v` | Top-level encryption/decryption controller |
| `initialization.v` | Initializes the ASCON state using key and nonce |
| `AD_Processing.v` | Processes associated data |
| `PT_CT.v` / `PT_CT_Processing.v` | Handles plaintext/ciphertext processing |
| `Final_layer.v` | Performs finalization and authentication tag generation |
| `Perm.v` | ASCON permutation control/datapath |
| `SBox.v` | Nonlinear substitution layer |
| `Linear_Sub.v` | Linear diffusion operation |
| `RND_Const.v` | Generates round constants |
| `RND_COUNTER.v` | Controls permutation round sequencing |
| Testbench | Drives encryption/decryption vectors and verifies outputs |

The modular structure separates:

- cryptographic transformation,
- round control,
- state management,
- block processing,
- and top-level sequencing.

This also makes individual components easier to simulate, debug, synthesize, and optimize.

---

# 5. ASCON Permutation

The permutation is the computational core of the implementation.

The 320-bit state is processed through the required number of rounds depending on the permutation being executed.

The RTL separates the major operations into individual components:

```text
              320-bit State
                    |
                    v
          +-------------------+
          | Round Constant    |
          +-------------------+
                    |
                    v
          +-------------------+
          | S-Box /           |
          | Substitution      |
          +-------------------+
                    |
                    v
          +-------------------+
          | Linear Diffusion  |
          +-------------------+
                    |
                    v
              320-bit State
```

### Round Constant Generation

The round-constant module generates the constant corresponding to the current permutation round.

The implementation supports the required round configurations through the round-count parameterization used by the RTL.

### Nonlinear Layer

The S-box provides the nonlinear transformation required by the ASCON permutation.

### Linear Layer

The linear diffusion stage applies the word-level rotations and XOR operations required to provide diffusion across the state.

### Round Counter

The round counter determines the current permutation round and allows the permutation controller to determine when the required number of rounds has been completed.

---

# 6. Initialization

The initialization stage constructs the initial ASCON state from:

- initialization vector,
- key,
- and nonce.

The resulting state is then processed through the required initialization permutation.

Conceptually:

```text
       IV
       |
       +------+
              |
Key ----------+-----> Initial State
              |
Nonce --------+
              |
              v
       Initialization
        Permutation
              |
              v
       Initialized State
```

The completion of initialization is indicated to the top-level controller through the `finish` handshake signal.

---

# 7. Associated Data Processing

Associated Data (AD) is authenticated but does not form part of the encrypted plaintext.

The implementation supports an input AD buffer of:

```text
1024 bits
```

with an explicit input length:

```text
ad_length[10:0]
```

This allows the processing stage to distinguish between valid associated-data bits and unused input-buffer bits.

The AD processing stage handles:

- block extraction,
- block processing,
- final partial-block handling,
- padding,
- permutation invocation,
- and state update.

The output of the AD stage becomes the input state for plaintext/ciphertext processing.

---

# 8. Plaintext / Ciphertext Processing

The plaintext/ciphertext processing stage supports both encryption and decryption operation.

The input interface includes:

```text
text
text_length
mode
state
start
```

with a 1024-bit data buffer and an explicit 11-bit length field.

The processing flow is conceptually:

```text
                 State
                   |
                   v
       +-----------------------+
       | PT / CT Block         |
       | Processing            |
       +-----------------------+
             |           |
             |           |
        Encryption   Decryption
             |           |
             v           v
          Ciphertext   Plaintext
             |
             v
       Updated ASCON State
```

The same underlying ASCON state and permutation architecture is used for the two operation modes.

---

# 9. Finalization and Authentication Tag

The final stage performs the final key-dependent transformation and generates the authentication tag.

The finalization stage receives:

```text
320-bit state
128-bit key
```

and produces:

```text
128-bit authentication tag
```

The completion of this stage is communicated using the `Done` handshake signal.

The tag generated during encryption is also compared against the tag generated during decryption during simulation verification.

---

# 10. Top-Level Interface

The current RTL top-level interface exposes the complete cryptographic datapath:

```text
clk
rst
start

key
nonce

ad
ad_length

text
text_length

mode

out_text
Tag
Done
```

The principal data widths are:

| Signal | Width |
|---|---:|
| Key | 128 bits |
| Nonce | 128 bits |
| ASCON State | 320 bits |
| Associated Data | 1024 bits |
| AD Length | 11 bits |
| Plaintext/Ciphertext | 1024 bits |
| Text Length | 11 bits |
| Output Text | 1024 bits |
| Authentication Tag | 128 bits |

The wide interface is intentional at the current RTL verification stage because it allows complete test vectors to be supplied directly to the design.

For physical FPGA deployment, this interface will be wrapped by a board-level interface such as UART, AXI, BRAM, or another suitable host interface rather than connecting the entire wide datapath directly to FPGA package pins.

---

# 11. Functional Verification

The design was verified using a Vivado XSim testbench.

The testbench performs both:

1. Encryption
2. Decryption

and verifies the resulting ciphertext, plaintext, authentication tag, and completion signal.

The simulation testbench also checks consistency between the encryption and decryption operations.

---

# 12. Encryption Test Vector

The following test vector was used in the current RTL simulation.

### Key

```text
000102030405060708090a0b0c0d0e0f
```

### Nonce

```text
000102030405060708090a0b0c0d0e0f
```

### Associated Data

```text
000102030405060708090a0b0c0d0e0f
```

### Plaintext

```text
112233445566778899aabbccddeeff00
```

The current simulation uses:

```text
AD length   = 128 bits
Text length = 128 bits
```

---

# 13. Encryption Result

The simulation produced the following ciphertext:

```text
b4606c5bd9d564008db24363aff45731
```

Authentication tag:

```text
3729af8d72387e89bf9fbce456739d8a
```

Completion:

```text
Done_enc = 1
```

Therefore, the encryption operation completed successfully for the tested input.

---

# 14. Decryption Result

The ciphertext generated during encryption was subsequently supplied to the decryption operation.

### Ciphertext

```text
b4606c5bd9d564008db24363aff45731
```

### Recovered Plaintext

```text
112233445566778899aabbccddeeff00
```

### Generated Decryption Tag

```text
3729af8d72387e89bf9fbce456739d8a
```

### Completion

```text
Done_dec = 1
```

The recovered plaintext matches the original plaintext, and the authentication tag generated during decryption matches the encryption tag.

---

# 15. Automated Verification Results

The testbench performs explicit checks on the major outputs.

```text
PASS: Encryption ciphertext
PASS: Decrypted plaintext
PASS: Tag ENC == Tag DEC
PASS: Done signal

================================
        ASCON TEST PASSED
================================
```

The simulation completed with:

```text
$finish called at time : 1295 ns
```

This provides functional RTL-level evidence that the implemented encryption and decryption datapaths operate consistently for the tested vector.

---

# 16. Simulation Flow

The verification flow used in Vivado is:

```text
             Verilog RTL
                 |
                 v
             Testbench
                 |
                 v
          Vivado XSim
                 |
       +---------+---------+
       |                   |
       v                   v
 Encryption            Decryption
       |                   |
       +---------+---------+
                 |
                 v
       Automated Comparison
                 |
                 v
            TEST PASSED
```

The waveform verifies the control sequence, input application, processing activity, output generation, and `Done` signaling.

---

# 17. FPGA Synthesis

After functional verification, the RTL was synthesized using the Vivado synthesis flow.

The current synthesis result provides an initial estimate of the hardware required by the design.

The major reported resources are:

| Resource | Used | Available | Approx. Utilization |
|---|---:|---:|---:|
| Slice LUTs | 544 | 41,000 | ~1% |
| Slice Registers | 652 | 82,000 | ~1% |
| Bonded IOB | 649 | 300 | >100% |
| BUFGCTRL | 1 | 32 | ~3% |

The logic resource usage of the cryptographic datapath is therefore relatively small compared with the available LUT and register resources of the configured FPGA device.

However, the current I/O utilization is not representative of the eventual hardware architecture.

---

# 18. Important I/O Constraint Consideration

The synthesized top-level currently exposes very wide input and output buses directly as top-level FPGA ports.

This results in:

```text
Bonded IOB usage = 649
Available IOBs   = 300
```

Consequently, the current RTL top-level cannot be directly mapped to the available FPGA package pins.

Vivado also reports the following DRC warnings:

```text
NSTD-1
649 of 649 logical ports use IOSTANDARD = DEFAULT
```

and:

```text
UCIO-1
649 of 649 logical ports have no user assigned LOC constraint
```

These warnings occur because the current cryptographic core has not yet been wrapped in a board-specific physical interface.

This is a deliberate separation between the **algorithmic RTL stage** and the **FPGA board integration stage**.

The planned hardware architecture is:

```text
              External Host
                   |
             UART / AXI / BRAM
                   |
                   v
        +-----------------------+
        | FPGA Interface        |
        | Wrapper               |
        +---------+-------------+
                  |
                  v
        +-----------------------+
        | ASCON TOP             |
        | Cryptographic Core    |
        +-----------------------+
                  |
                  v
              Result / Tag
                  |
                  v
             Host Interface
```

The wide cryptographic signals will remain internal to the FPGA.

Only a small number of physical FPGA pins will be required for the final hardware interface, such as:

- clock,
- reset,
- UART RX/TX,
- status/debug signals,
- or other board-specific interfaces.

---

# 19. Synthesis Warning

Vivado reports the following synthesis warning:

```text
[Netlist 29-101]

'Perm' is not ideal for floorplanning, since the cellview
'Perm' contains a large number of primitives.
```

This warning does not indicate a functional failure of the RTL.

It indicates that the synthesized `Perm` hierarchy contains a relatively large number of primitive elements, making manual floorplanning less convenient.

At the current stage, no manual floorplanning is being performed.

The warning is therefore treated as an implementation observation rather than a functional error.

If future optimization requires physical placement control, the permutation hierarchy can be revisited with synthesis hierarchy preservation and physical-design constraints.

---

# 20. Timing Analysis

The current synthesis timing report shows:

| Timing Metric | Result |
|---|---:|
| WNS | `inf` |
| TNS | `0.000 ns` |
| Failing endpoints | `0` |
| Total endpoints | `2271` |
| WHS | `inf` |
| THS | `0.000 ns` |
| Hold violations | `0` |

However, Vivado explicitly reports:

```text
There are no user specified timing constraints.
```

Therefore, these results **must not be interpreted as a timing-closure result or maximum operating frequency**.

No meaningful Fmax can be extracted from the current report because the design clock has not yet been constrained.

The next timing-analysis stage will introduce an appropriate clock constraint, for example:

```tcl
create_clock -period <clock_period> [get_ports clk]
```

followed by synthesis/implementation timing analysis.

The eventual target will be to evaluate:

- setup slack,
- hold slack,
- critical path,
- logic delay,
- routing delay,
- clock uncertainty,
- and maximum achievable operating frequency.

---

# 21. Preliminary Power Analysis

Vivado generated the following synthesis-level power estimate:

| Parameter | Result |
|---|---:|
| Total On-Chip Power | 29.15 W |
| Dynamic Power | 28.873 W |
| Device Static Power | 0.277 W |
| Junction Temperature | 79.9 °C |
| Thermal Margin | 5.1 °C |
| Effective ΘJA | 1.9 °C/W |
| Confidence Level | Low |

The dynamic power breakdown reported by Vivado is approximately:

| Component | Power |
|---|---:|
| Signals | 9.462 W |
| Logic | 7.111 W |
| I/O | 12.300 W |
| Clock Enable | 0.43 W |
| Static | 0.277 W |

### Important interpretation

The reported **29.15 W is a preliminary Vivado estimate and is not a measured FPGA power consumption result**.

The report itself indicates a **low confidence level**, and the current unconstrained wide I/O interface contributes significantly to the estimated I/O power.

In particular:

```text
I/O power = 12.300 W
```

is strongly influenced by the current 649-port top-level interface.

After introducing a realistic FPGA interface, applying actual I/O standards, clock constraints, switching activity, and implementation results, the power estimate should be regenerated.

Final hardware power should ultimately be measured on the physical FPGA board.

---

# 22. Current Hardware Implementation Status

The project currently has two distinct validation stages.

### Stage 1 — Algorithmic RTL Validation

```text
RTL
 |
 v
Simulation
 |
 +--> Encryption PASS
 |
 +--> Decryption PASS
 |
 +--> Plaintext recovery PASS
 |
 +--> Tag comparison PASS
 |
 +--> Done signal PASS
```

This stage is currently completed for the tested vector.

### Stage 2 — FPGA Physical Validation

```text
RTL
 |
 v
Synthesis
 |
 v
Constraints
 |
 v
Implementation
 |
 v
Timing Analysis
 |
 v
Bitstream
 |
 v
FPGA Board
 |
 v
Hardware Validation
```

This stage is currently in progress.

---

# 23. Planned FPGA Deployment Architecture

The next hardware-development step is to separate the cryptographic core from the physical board interface.

The current structure:

```text
                 TOP
                  |
       +----------+----------+
       |                     |
  1024-bit AD           1024-bit Text
       |                     |
       +----------+----------+
                  |
              ASCON Core
```

will eventually be interfaced through a narrower communication mechanism:

```text
             PC / Host
                 |
              UART/AXI
                 |
                 v
       +-------------------+
       | FPGA Wrapper      |
       |                   |
       | Input Buffer      |
       | Control FSM       |
       | Output Buffer     |
       +---------+---------+
                 |
                 v
       +-------------------+
       | ASCON Core        |
       |                   |
       | 320-bit State     |
       | Permutation       |
       | AD Processing     |
       | PT/CT Processing  |
       | Finalization      |
       +-------------------+
                 |
                 v
             Result
```

This approach avoids exposing the internal 1024-bit buses as physical FPGA I/O and provides a practical path toward board-level testing.

---

# 24. Optimization Opportunities

The current synthesis results provide a baseline for future hardware optimization.

Potential optimization directions include:

### 24.1 Permutation Architecture

The permutation currently represents the dominant cryptographic datapath.

Future implementations can investigate:

- iterative round architecture,
- partial unrolling,
- full unrolling,
- resource sharing,
- pipelining,
- and round-level register placement.

These architectures provide different trade-offs between:

```text
Area <-------> Throughput
Latency <-----> Frequency
Power <-------> Performance
```

The current implementation establishes a functional baseline against which these architectures can be compared.

---

### 24.2 Timing Optimization

Once a clock constraint is applied, the critical path can be identified.

Likely areas of interest include:

- S-box combinational depth,
- XOR networks,
- rotation/diffusion logic,
- state update paths,
- and control-to-datapath paths.

The resulting critical path will determine the next optimization target.

---

### 24.3 Interface Optimization

The current wide interface should be replaced by a practical communication architecture.

Possible approaches include:

- UART,
- AXI-Stream,
- AXI-Lite,
- BRAM-based buffering,
- or a custom streaming interface.

The choice will depend on the final application and required throughput.

---

### 24.4 Power Optimization

After implementation constraints and realistic switching activity are available, power optimization can target:

- unnecessary switching,
- clock enable usage,
- register activity,
- datapath sharing,
- I/O activity,
- and operating frequency.

Power should eventually be evaluated using both Vivado implementation analysis and physical measurements.

---

# 25. Verification Strategy

The verification methodology follows a layered approach.

```text
                Unit-Level Verification
                         |
             +-----------+-----------+
             |                       |
             v                       v
          S-Box                 Linear Layer
             |                       |
             +-----------+-----------+
                         |
                         v
                  Permutation
                         |
                         v
              Processing Stages
                         |
                         v
                 TOP Controller
                         |
                         v
              Encryption / Decryption
                         |
                         v
                End-to-End Test
```

The current end-to-end test verifies:

1. Encryption completes.
2. Ciphertext is generated.
3. Decryption accepts the generated ciphertext.
4. Original plaintext is recovered.
5. Encryption and decryption tags match.
6. Completion signals assert correctly.

This provides a functional baseline before moving to physical FPGA validation.

---

# 26. Current Reported Results

The current project results can be summarized as follows:

| Category | Current Result |
|---|---|
| RTL simulation | Passed |
| Encryption | Passed |
| Decryption | Passed |
| Plaintext recovery | Passed |
| Tag consistency | Passed |
| Done signal | Passed |
| Simulation completion | 1295 ns |
| LUT utilization | 544 / 41,000 |
| Register utilization | 652 / 82,000 |
| Current IOB usage | 649 / 300 |
| BUFGCTRL | 1 / 32 |
| Synthesis power estimate | 29.15 W |
| Power confidence | Low |
| Timing constraints | Not yet applied |
| Physical implementation | Pending |
| Bitstream | Pending |
| Hardware measurement | Pending |

The resource numbers above are **post-synthesis results** and should not be interpreted as final post-place-and-route utilization.

---

# 27. Repository Structure

A recommended repository organization is:

```text
Ascon_Cipher/
│
├── RTL/
│   ├── TOP.v
│   ├── initialization.v
│   ├── AD_Processing.v
│   ├── PT_CT.v
│   ├── Final_layer.v
│   ├── Perm.v
│   ├── SBox.v
│   ├── Linear_Sub.v
│   ├── RND_Const.v
│   └── RND_COUNTER.v
│
├── Simulation/
│   └── TOP_TB_2.v
│
├── Results/
│   ├── Simulation/
│   │   ├── waveform.png
│   │   └── simulation_pass.png
│   │
│   └── Synthesis/
│       ├── utilization.png
│       ├── timing.png
│       ├── power.png
│       ├── drc.png
│       └── device_view.png
│
├── Constraints/
│   └── README.md
│
├── README.md
└── LICENSE
```

---

# 28. Development Roadmap

The project is being developed incrementally.

### Completed

- [x] ASCON state datapath
- [x] S-box implementation
- [x] Linear diffusion layer
- [x] Round constant generation
- [x] Round counter
- [x] Permutation architecture
- [x] Initialization
- [x] Associated Data processing
- [x] Plaintext/Ciphertext processing
- [x] Finalization
- [x] Authentication tag generation
- [x] Encryption simulation
- [x] Decryption simulation
- [x] End-to-end verification
- [x] Vivado synthesis
- [x] Initial resource analysis

### In Progress

- [ ] Board-specific pin constraints
- [ ] Clock constraints
- [ ] Post-implementation timing analysis
- [ ] FPGA interface wrapper
- [ ] Bitstream generation

### Planned

- [ ] FPGA hardware bring-up
- [ ] UART/host interface
- [ ] On-chip debugging using ILA
- [ ] Hardware ciphertext/tag verification
- [ ] Throughput measurement
- [ ] Latency measurement
- [ ] Maximum operating frequency characterization
- [ ] Hardware power measurement
- [ ] Resource/performance optimization
- [ ] Comparison of iterative and pipelined architectures

---

# 29. Performance Characterization — Planned

Once timing constraints and physical implementation are complete, the following parameters will be measured:

| Metric | Status |
|---|---|
| Maximum clock frequency | Pending |
| Clock period | Pending |
| Encryption latency | Pending |
| Decryption latency | Pending |
| Throughput | Pending |
| LUT utilization | Initial result available |
| Register utilization | Initial result available |
| BRAM utilization | To be evaluated |
| DSP utilization | To be evaluated |
| Static power | Preliminary estimate available |
| Dynamic power | Preliminary estimate available |
| Total measured FPGA power | Pending |

For a hardware cryptographic accelerator, throughput and latency will ultimately be evaluated together with area and power rather than using a single metric.

---

# 30. Engineering Notes

Several results in the current Vivado reports require careful interpretation.

### Timing

The current:

```text
WNS = inf
TNS = 0
```

does **not** establish timing closure because:

```text
No user specified timing constraints
```

are currently present.

### Power

The current:

```text
29.15 W
```

is a synthesis-level Vivado estimate with:

```text
Confidence = Low
```

and should not be reported as measured board power.

### I/O

The current:

```text
649 IOBs
```

does not mean that the cryptographic core intrinsically requires 649 external pins.

It is primarily a consequence of exposing the complete wide test-oriented interface at the current top level.

### Synthesis Warning

The `Netlist 29-101` warning concerning the `Perm` hierarchy is an implementation/floorplanning observation and is not a functional failure.

---

# 31. Project Objective

The long-term objective of this implementation is to develop a complete FPGA-based ASCON cryptographic accelerator with:

```text
        Functional Correctness
                 +
        Hardware Efficiency
                 +
        Timing Closure
                 +
        Low-Latency Operation
                 +
        Practical FPGA Interface
                 +
        Physical Hardware Validation
```

The current RTL implementation establishes the functional cryptographic foundation. The next stage focuses on transforming the verified RTL into a constrained, physically implementable FPGA design and subsequently characterizing its performance on hardware.

---

# 32. Summary

This project implements ASCON-AEAD128 at the RTL level using a modular Verilog architecture.

The current design includes the complete cryptographic processing chain:

```text
Key + Nonce
     |
     v
Initialization
     |
     v
Associated Data
     |
     v
Plaintext / Ciphertext
     |
     v
Finalization
     |
     +------> Authentication Tag
     |
     v
Encrypted / Decrypted Data
```

The implementation has been **functionally verified in Vivado XSim for both encryption and decryption**. The tested encryption/decryption sequence successfully reproduced the original plaintext and produced matching authentication tags.

Initial Vivado synthesis reports:

```text
544 LUTs
652 Registers
1 BUFGCTRL
```

indicating relatively low logic utilization of the configured FPGA resources.

The current I/O utilization is intentionally treated as an intermediate RTL-stage result because the wide verification-oriented interface is not yet mapped to a practical board-level interface.

The next development phase is therefore focused on:

```text
RTL Verification
       ↓
Clock & I/O Constraints
       ↓
FPGA Implementation
       ↓
Timing Closure
       ↓
Bitstream Generation
       ↓
Hardware Bring-Up
       ↓
Performance Characterization
       ↓
Optimization
```

This progression will allow the project to move from a functionally verified cryptographic RTL design toward a fully characterized FPGA implementation.

---

## Author

**Poorna Sai Reddy**  
B.Tech — Electrical Engineering  
Indian Institute of Technology Indore

---

## Tools & Technologies

- **Verilog HDL**
- **AMD/Xilinx Vivado**
- **Vivado XSim**
- **FPGA RTL Design**
- **Digital Design**
- **Lightweight Cryptography**
- **Authenticated Encryption**
- **Hardware Verification**
- **FPGA Synthesis & Implementation**

---

## License

This project is intended for academic, research, and educational purposes.

See `LICENSE` for licensing information.
