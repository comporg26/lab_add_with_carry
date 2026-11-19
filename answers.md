# Answers — second 6502 lab

Please write your answers below each question.

1. What did the program return when it calculated 255 + 1? Why was the answer not 256?

   Answer:

2. In the trace of 255 + 1, what was the value of A after `ADC`? Was the carry flag set or clear? How could you tell?

   Answer:

3. How do `i_low` and `i_high` together represent the number 11969? Why do we need two bytes?

   Answer:

4. Why must we **not** clear the carry flag between adding the low bytes and the high bytes?

   Answer:

5. What values did your program store in `result_low` and `result_high`? What did the trace show about the carry after the low-byte addition?

   Answer:

6. What happened when you temporarily inserted `CLC` before the high-byte addition? Why?

   Answer:

7. (Optional) What happened when you added `$00FF` and `$0001`? What were the two result bytes?

   Answer:
