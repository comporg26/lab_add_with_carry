# A Gentle Introduction to Carry on the 6502

## Introduction

Last time, you all wrote a program for the 6502. You used an accumulator,
put numbers into memory, and calculated an expression. You also used two
instructions, `CLC` and `SEC`, without really knowing why they were needed.

Today we'll find out what `CLC` does.

The 6502 is an **8-bit processor**. Its accumulator, A, can hold one byte.
That means it can hold numbers from 0 to 255 if we interpret the byte as an
unsigned number.

But what if we want to add two numbers and the answer is bigger than 255?
And what if we want to add numbers like 11969 and 6039? Can an 8-bit CPU do
that at all?

Yes, it can. It just needs a little help from us.

We'll use the same `cl65` and `sim65` tools on `the.hell.am` as in the first
lab. Open `test.s` and `answers.md`; we'll be using both.

## 1. What happens to 255 + 1?

Look at the code already in `test.s`:

```asm
    lda #255
    clc
    adc #1
    sta result_low
```

You know `LDA`: it loads a number into A. You know `ADC`: it adds a number
to A. But look closely at what we've asked the processor to do.

The accumulator can hold only eight bits:

```text
    11111111       255
  + 00000001         1
  ----------
  1 00000000       256
  ^
  the ninth bit
```

Where does that ninth bit go? There is no room for it in A.

Build and run the example:

```sh
make
sim65 test.prg
echo $?
```

You should get **0**, not 256. We haven't made a mistake in the assembly.
The accumulator contains the low eight bits of the answer.

But the processor hasn't forgotten that ninth bit. It keeps it in a
one-bit part of its **status register**, called the **carry flag**, or **C**.
After this addition, A is 0 and C is 1.

Please open `answers.md` and answer the first question.

## 2. Let's see the carry flag

We have something nice on our server now: a newer version of `sim65` can
show us what the processor is doing.

At the beginning of `_main`, you'll see:

```asm
    lda #$16
    sta $FFCB
```

This writes to a special address understood by `sim65`. It enables tracing
of the instructions that follow. Later, the program writes zero to the
same address to turn tracing off.

See? An ordinary `STA` instruction can control something other than a RAM
variable. On a real 6502 computer, some memory addresses can control
hardware devices. Here we're controlling a simulated device.

Run:

```sh
sim65 test.prg
```

Look for the instructions `adc` and `sta` in the output. The trace includes
the accumulator, such as `A=00`, and the status flags, such as
`Flags=nvdiZC`.

**An uppercase `C` means the carry flag is set.** A lowercase `c` means
it is clear.

One small detail: each trace line shows the registers and flags **before**
that instruction executes. To see the result of `ADC`, look at the *next*
instruction's line. In our example, that's `STA`.

Please write in `answers.md` what A and C contain after `ADC`.

## 3. So what is ADC really doing?

`ADC` stands for **Add with Carry**. It actually adds three things:

```text
new A := old A + number + carry
```

The carry flag can be either 0 or 1. If the result doesn't fit in eight
bits, A keeps the low byte and C becomes 1. Otherwise, C becomes 0.

Now `CLC` makes sense, doesn't it? It stands for **Clear Carry**. If you
want an ordinary addition without an extra 1 left over from a previous
operation, clear C first:

```asm
    lda #10
    clc
    adc #20       ; A is now 30
```

But there are times when we **don't** want to clear it. We'll see why in a
moment.

## 4. Two bytes make a larger number

A byte holds eight bits. Two bytes can hold sixteen bits, allowing us to
represent unsigned numbers from 0 to 65535.

We can't put all sixteen bits in the 6502's accumulator at once. Instead,
we can keep them in two neighbouring memory locations: a *low byte* and a
*high byte*.

Look at the beginning of `test.s`:

```asm
.segment "DATA"
i_low:   .byte $C1
i_high:  .byte $2E
j_low:   .byte $97
j_high:  .byte $17
```

The `$` means the number is written in hexadecimal. So `$C1` is 193 in
decimal, and `$2E` is 46.

The two bytes of `i` represent one number:

```text
       high   low
        $2E   $C1

i = $2EC1 = 11969
```

And the two bytes of `j` represent another:

```text
       high   low
        $17   $97

j = $1797 = 6039
```

Notice that in our file the low byte is declared first. When these bytes
are placed next to each other in memory, this is called **little-endian**
representation. You may remember that term from our x86-64 classes.

We have also reserved two bytes for the answer:

```asm
.segment "BSS"
result_low:  .res 1
result_high: .res 1
```

## 5. Your task: add two 16-bit numbers

Your task is to calculate:

```text
result := i + j
```

That is:

```text
11969 + 6039 = 18008
```

Sounds like a large number for an 8-bit processor? Let's think about how
we might do it on paper.

First, add the **low bytes**. Save the low byte of their sum in
`result_low`. If the addition produces a carry, the processor remembers
it in C.

Next, add the **high bytes**, **including the carry from the first
addition**. Save that result in `result_high`.

Here's the important part: you must use `CLC` before adding the low bytes,
but **do not put another `CLC` before adding the high bytes**. We need the
carry from the first addition! `LDA` and `STA` do not erase it.

Now replace the four instructions of the 255 + 1 example in `test.s` with
your own code. Use the instructions you already know:

* `LDA` to load a byte into A.
* `CLC` to start the addition with carry cleared.
* `ADC` to add a byte and the carry flag to A.
* `STA` to save a byte in memory.

You don't need loops, functions, or the stack. Just add one byte, then the
other.

One question before you start: **If `ADC` uses the carry flag, why is it
important that the second addition does not start with `CLC`?** Write your
answer in `answers.md`.

## 6. Did it work?

Build and run:

```sh
make
make run
```

You'll see the trace of your code, followed by the low byte of the answer,
printed in decimal.

The correct 16-bit answer is `$4658`, so its two bytes should be:

```text
low byte:  $58 = 88
high byte: $46 = 70
```

How do we check both bytes? `sim65` uses the accumulator as an exit status,
and an exit status holds only one byte. The Makefile handles this for you:
it builds the same source twice, choosing a different result byte to return
each time.

Run:

```sh
make test
```

Once your program is correct, you should see:

```text
Low byte:  88 (expected 88)
High byte: 70 (expected 70)
```

If the low byte is correct but the high byte is 69, think about the carry
flag. Did you accidentally clear it between the two additions?

Please also look at the trace. Find the first `ADC` and the instruction
after it. What is the carry flag now? What does the second `ADC` do with it?
Write your observations in `answers.md`.

## 7. A small experiment

Once you have a working program, try **temporarily** inserting another
`CLC` immediately before the instruction that adds the high bytes.

Run `make test` again.

Did the result change? Why?

Write your answer in `answers.md`, then remove the extra `CLC` and check
that `make test` succeeds again.

## 8. If you have time

Try adding `$00FF` and `$0001` by changing the four input bytes:

```text
i = $00FF
j = $0001
```

What should the two bytes of the result be? Predict them before running
the program. Check the trace, and write down your observation.

Afterwards, restore the original values so that `make test` passes.

## What to submit

Please open `answers.md` and write your answers below its questions.
Then commit and push:

* `test.s` with your completed 16-bit addition.
* `answers.md` with your observations.

Don't commit the `.prg` files; `make` generates them.

For reference, you can read the [6502 instruction set](https://www.masswerk.at/6502/6502_instruction_set.html)
and the [sim65 documentation](https://cc65.github.io/doc/sim65.html).

Have fun!
