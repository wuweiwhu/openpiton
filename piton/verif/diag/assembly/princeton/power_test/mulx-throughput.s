/*
* Copyright (c) 2016 Princeton University
* All rights reserved.
* 
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
*     * Redistributions of source code must retain the above copyright
*       notice, this list of conditions and the following disclaimer.
*     * Redistributions in binary form must reproduce the above copyright
*       notice, this list of conditions and the following disclaimer in the
*       documentation and/or other materials provided with the distribution.
*     * Neither the name of Princeton University nor the
*       names of its contributors may be used to endorse or promote products
*       derived from this software without specific prior written permission.
* 
* THIS SOFTWARE IS PROVIDED BY PRINCETON UNIVERSITY "AS IS" AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL PRINCETON UNIVERSITY BE LIABLE FOR ANY
* DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/
/****************************************************************
 * Name: princeton-test-test.s
 * Date: December 17, 2013
 *
 * Description: Test adding a test to the OpenSPARC T1 regressions
 *
 ****************************************************************/

! Number of loop iterations
#define LOOP_ITERATIONS 10
#define EXPECTED_SUM 45

/*********************************************************/
#include "boot.s"
#include "piton_def.h"

.text
.global main
main:
    setx    hp_start, %l1, %l0
    jmp     %l0
    nop

    .global return_from_hp
return_from_hp:
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! User space for text for all threads
    !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    ! *_tight tests should never reach this point
    PITON_UPUTS(user_sucks_str, %l0)
    mov     %g0, %g1
    setx    test_data, %l0, %l4
    setx    0x55555555, %l0, %g2
    mov     %g2, %g3
profile_loop:
    PITON_UPUTS(prof_str, %l0)
    PITON_UPRINT_REG_NL(%g1, %l0)
    mov     SPARC_PIC, %l0
    rd      %tick, %l2
    !!! Start: profiling code
    mulx    %g2, %g3, %g4
    mulx    %g2, %g3, %g5
    mulx    %g2, %g3, %g6
    mulx    %g2, %g3, %g7
    mulx    %g2, %g3, %g4
    mulx    %g2, %g3, %g5
    mulx    %g2, %g3, %g6
    mulx    %g2, %g3, %g7
    mulx    %g2, %g3, %g4
    mulx    %g2, %g3, %g5
    mulx    %g2, %g3, %g6
    mulx    %g2, %g3, %g7
    mulx    %g2, %g3, %g4
    mulx    %g2, %g3, %g5
    mulx    %g2, %g3, %g6
    mulx    %g2, %g3, %g7
    !!! End: profiling code
    rd      %tick, %l3
    mov     SPARC_PIC, %l1
    ! Print last loaded value
    PITON_UPUTS(addr_str, %l6)
    PITON_UPRINT_REG_NL(%l4, %l6)
    PITON_UPUTS(loaded_str, %l6)
    PITON_UPRINT_REG_NL(%l5, %l6)
    ! Calculate number of ticks
    sub     %l3, %l2, %l3
    PITON_UPUTS(ticks_str, %l6)
    PITON_UPRINT_REG_NL(%l3, %l6)
    ! Calculate number of events
    setx    0xffffffff, %l5, %l6
    and     %l0, %l6, %l0
    and     %l1, %l6, %l1
    sub     %l1, %l0, %l1
    PITON_UPUTS(event_str, %l6)
    PITON_UPRINT_REG_NL(%l1, %l6)
    PITON_UPUTS(nl_string, %l0)
    add     %l4, PITON_L2_CL_SIZE, %l4
    add     %g1, 1, %g1
    cmp     %g1, 3
    bne     profile_loop
    nop
    ba      test_good_end
    nop
    nop
test_good_end:
    ta      T_GOOD_TRAP
    ba      test_end    
    nop
test_bad_end:
    ta      T_BAD_TRAP
    ba      test_end
    nop
test_end:
    nop
    nop

    

!==========================
.data
.align 0x1fff+1

.global test_data

    .align 64
test_data:
    .xword 0x0123456789abcdef
    .align 64


SECTION .ACTIVE_THREAD_SEC TEXT_VA=0x0000000040008000
   attr_text {
        Name = .ACTIVE_THREAD_SEC,
        VA= 0x0000000040008000,
        PA= ra2pa(0x0000000040008000,0),
        RA= 0x0000000040008000,
        part_0_i_ctx_nonzero_ps0_tsb,
        part_0_d_ctx_nonzero_ps0_tsb,
        TTE_G=1, TTE_Context=PCONTEXT, TTE_V=1, TTE_Size=0, TTE_NFO=0,
        TTE_IE=0, TTE_Soft2=0, TTE_Diag=0, TTE_Soft=0,
        TTE_L=0, TTE_CP=1, TTE_CV=1, TTE_E=0, TTE_P=0, TTE_W=1
        }
   attr_text {
        Name = .ACTIVE_THREAD_SEC,
        hypervisor
        }

.text

    .global hp_start
hp_start:
    ta      T_CHANGE_HPRIV
    call    piton_multithread_init
    nop
    ! Jump back to user code
    ta      T_CHANGE_NONHPRIV
    setx    return_from_hp, %l0, %l1
    jmp %l1
    nop

#include "piton_common.s"
#include "piton_multithread_init.s"