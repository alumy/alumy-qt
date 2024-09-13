var srs =
[
    [ "Purpose and Scope", "srs.html#srs_scope", [
      [ "Revision History", "srs.html#srs_history", null ],
      [ "About QP Framework", "srs.html#srs_about", null ],
      [ "Audience", "srs.html#srs_audience", null ],
      [ "Document Conventions", "srs.html#srs_conv", null ],
      [ "General Requirement UIDs", "srs.html#srs_uid", null ],
      [ "Use of Shall/Should/etc.", "srs.html#srs_lang", [
        [ "\"shall\"", "srs.html#srs_lang_shall", null ],
        [ "\"should\"", "srs.html#srs_lang-should", null ],
        [ "\"may\"", "srs.html#srs_lang-may", null ],
        [ "\"must not\"", "srs.html#srs_lang-must-not", null ]
      ] ],
      [ "Document Organization", "srs.html#srs_org", null ],
      [ "References", "srs.html#srs_ref", null ]
    ] ],
    [ "Overview", "srs_over.html", [
      [ "Context and Functional Decomposition", "srs_over.html#srs_over-ctxt", [
        [ "Event-Driven Paradigm", "srs_over.html#srs_over_ed", null ],
        [ "Inversion of Control", "srs_over.html#srs_over_inv", null ],
        [ "Framework, NOT a Library", "srs_over.html#srs_over_frame", null ],
        [ "Active Objects", "srs_over.html#srs_intro_ao", null ],
        [ "State Machines", "srs_over.html#srs_over_sm", null ]
      ] ],
      [ "Portability & Configurability of QP", "srs_over.html#srs_over-conf", [
        [ "Compile-Time Configurability", "srs_over.html#srs_conf_compile", null ],
        [ "Run-Time Configurability", "srs_over.html#srs_conf_run", null ]
      ] ]
    ] ],
    [ "Events", "srs_evt.html", [
      [ "Concepts & Definitions", "srs_evt.html#srs_evt-def", [
        [ "Event Signal", "srs_evt.html#srs_evt-sig", null ],
        [ "Event Parameters", "srs_evt.html#srs_evt-par", null ]
      ] ],
      [ "Requirements", "srs_evt.html#srs_evt-req", [
        [ "REQ-QP-01_00", "srs_evt.html#REQ-QP-01_00", null ],
        [ "REQ-QP-01_20", "srs_evt.html#REQ-QP-01_20", null ],
        [ "REQ-QP-01_21", "srs_evt.html#REQ-QP-01_21", null ],
        [ "REQ-QP-01_22", "srs_evt.html#REQ-QP-01_22", null ],
        [ "REQ-QP-01_23", "srs_evt.html#REQ-QP-01_23", null ],
        [ "REQ-QP-01_30", "srs_evt.html#REQ-QP-01_30", null ],
        [ "REQ-QP-01_31", "srs_evt.html#REQ-QP-01_31", null ],
        [ "REQ-QP-01_40", "srs_evt.html#REQ-QP-01_40", null ],
        [ "REQ-QP-01_41", "srs_evt.html#REQ-QP-01_41", null ]
      ] ]
    ] ],
    [ "State Machines", "srs_sm.html", [
      [ "Concepts & Definitions", "srs_sm.html#srs_sm-def", [
        [ "State", "srs_sm.html#srs_sm-state", null ],
        [ "Transition", "srs_sm.html#srs_sm-tran", null ],
        [ "State Machine", "srs_sm.html#srs_sm-sm", null ],
        [ "Hierarchical State Machine", "srs_sm.html#srs_sm-hier", null ],
        [ "State Machine Implementation Strategy", "srs_sm.html#srs_sm-impl", null ],
        [ "Dispatching Events to a State Machine in QP Framework", "srs_sm.html#srs_sm-dispatch", [
          [ "State Machine Specification", "srs_sm.html#srs_sm-spec", null ],
          [ "State Machine Processor", "srs_sm.html#srs_sm-proc", null ],
          [ "Run To Completion (RTC) Processing", "srs_sm.html#srs_sm-rtc", null ]
        ] ]
      ] ],
      [ "Requirements", "srs_sm.html#srs_sm-req", [
        [ "REQ-QP-02_00", "srs_sm.html#REQ-QP-02_00", null ],
        [ "REQ-QP-02_10", "srs_sm.html#REQ-QP-02_10", null ],
        [ "REQ-QP-02_20", "srs_sm.html#REQ-QP-02_20", null ],
        [ "REQ-QP-02_21", "srs_sm.html#REQ-QP-02_21", null ],
        [ "REQ-QP-02_22", "srs_sm.html#REQ-QP-02_22", null ],
        [ "REQ-QP-02_23", "srs_sm.html#REQ-QP-02_23", null ],
        [ "REQ-QP-02_24", "srs_sm.html#REQ-QP-02_24", null ],
        [ "REQ-QP-02_25", "srs_sm.html#REQ-QP-02_25", null ],
        [ "REQ-QP-02_30", "srs_sm.html#REQ-QP-02_30", null ],
        [ "REQ-QP-02_31", "srs_sm.html#REQ-QP-02_31", null ],
        [ "REQ-QP-02_32", "srs_sm.html#REQ-QP-02_32", null ],
        [ "REQ-QP-02_33", "srs_sm.html#REQ-QP-02_33", null ],
        [ "REQ-QP-02_34", "srs_sm.html#REQ-QP-02_34", null ],
        [ "REQ-QP-02_35", "srs_sm.html#REQ-QP-02_35", null ],
        [ "REQ-QP-02_36", "srs_sm.html#REQ-QP-02_36", null ],
        [ "REQ-QP-02_37", "srs_sm.html#REQ-QP-02_37", null ],
        [ "REQ-QP-02_38", "srs_sm.html#REQ-QP-02_38", null ],
        [ "REQ-QP-02_39", "srs_sm.html#REQ-QP-02_39", null ],
        [ "REQ-QP-02_40", "srs_sm.html#REQ-QP-02_40", null ],
        [ "REQ-QP-02_50", "srs_sm.html#REQ-QP-02_50", null ],
        [ "REQ-QP-02_51", "srs_sm.html#REQ-QP-02_51", null ],
        [ "REQ-QP-02_52", "srs_sm.html#REQ-QP-02_52", null ],
        [ "REQ-QP-02_53", "srs_sm.html#REQ-QP-02_53", null ],
        [ "REQ-QP-02_54", "srs_sm.html#REQ-QP-02_54", null ],
        [ "REQ-QP-02_55", "srs_sm.html#REQ-QP-02_55", null ],
        [ "REQ-QP-02_56", "srs_sm.html#REQ-QP-02_56", null ]
      ] ]
    ] ],
    [ "Active Objects", "srs_ao.html", [
      [ "Concepts & Definitions", "srs_ao.html#srs_ao-def", [
        [ "Active Objects in QP Framework", "srs_ao.html#srs_ao-sys", null ],
        [ "Encapsulation", "srs_ao.html#srs_ao-enc", null ],
        [ "Asynchronous Communication", "srs_ao.html#srs_ao-asynch", null ]
      ] ],
      [ "Run-to-Completion (RTC)", "srs_ao.html#srs_ao-rtc", [
        [ "No Blocking", "srs_ao.html#srs_ao-block", null ],
        [ "Thread of Control", "srs_ao.html#srs_ao-thr", null ],
        [ "Active Object Priority", "srs_ao.html#srs_ao-prio", null ]
      ] ],
      [ "Requirements", "srs_ao.html#srs_ao-req", [
        [ "REQ-QP-03_00", "srs_ao.html#REQ-QP-03_00", null ],
        [ "REQ-QP-03_10", "srs_ao.html#REQ-QP-03_10", null ],
        [ "REQ-QP-03_11", "srs_ao.html#REQ-QP-03_11", null ],
        [ "REQ-QP-03_20", "srs_ao.html#REQ-QP-03_20", null ],
        [ "REQ-QP-03_30", "srs_ao.html#REQ-QP-03_30", null ]
      ] ]
    ] ],
    [ "Event Delivery", "srs_ed.html", [
      [ "Direct Event Posting", "srs_ed.html#srs_ed-post", null ],
      [ "Publish-Subscribe", "srs_ed.html#srs_ed-ps", null ],
      [ "Event Memory Management", "srs_ed.html#srs_ed-mem", [
        [ "Immutable Events", "srs_ed.html#srs_ed-imm", null ],
        [ "Mutable Events", "srs_ed.html#srs_ed_mutable", null ]
      ] ],
      [ "Zero-Copy Event Delivery", "srs_ed.html#srs_ed-zero", null ],
      [ "Requirements", "srs_ed.html#srs_ed-req", [
        [ "REQ-QP-04_00", "srs_ed.html#REQ-QP-04_00", null ]
      ] ]
    ] ],
    [ "Time Management", "srs_tm.html", [
      [ "Time Events", "srs_tm.html#srs_tm-te", null ],
      [ "System Clock Tick", "srs_tm.html#srs_tm-tick", null ],
      [ "Requirements", "srs_tm.html#srs_tm-req", [
        [ "REQ-QP-05_00", "srs_tm.html#REQ-QP-05_00", null ]
      ] ]
    ] ],
    [ "Software Tracing", "srs_qs.html", [
      [ "Requirements", "srs_qs.html#srs_qs-req", [
        [ "REQ-QP-06_00", "srs_qs.html#REQ-QP-06_00", null ]
      ] ]
    ] ],
    [ "Cooperative Run-to-Completion Kernel", "srs_qv.html", [
      [ "Theory of Operation", "srs_qv.html#srs_qv-theory", null ],
      [ "Requirements", "srs_qv.html#srs_qv-req", [
        [ "REQ-QP-07_00", "srs_qv.html#REQ-QP-07_00", null ]
      ] ]
    ] ],
    [ "Preemptive Run-to-Completion Kernel", "srs_qk.html", [
      [ "Theory of Operation", "srs_qk.html#srs_qk-theory", null ],
      [ "QK Features", "srs_qk.html#qsrs_qk-feat", [
        [ "Scheduler Locking", "srs_qk.html#qsrs_qk-lock", null ]
      ] ],
      [ "Requirements", "srs_qk.html#srs_qk-req", [
        [ "REQ-QP-08_00", "srs_qk.html#REQ-QP-08_00", null ],
        [ "REQ-QP-08_10", "srs_qk.html#REQ-QP-08_10", null ]
      ] ]
    ] ],
    [ "Preemptive Dual-Mode Kernel", "srs_qxk.html", [
      [ "Theory of Operation", "srs_qxk.html#srs_qxk-theory", null ],
      [ "Basic Threads", "srs_qxk.html#srs_qxk-basic", null ],
      [ "Extended Threads", "srs_qxk.html#srs_qxk-ext", null ],
      [ "QXK Feature Summary", "srs_qxk.html#srs_qxk-feat", [
        [ "Scheduler Locking", "srs_qxk.html#srs_qxk-lock", null ],
        [ "Thread Local Storage", "srs_qxk.html#srs_qxk-tls", null ]
      ] ],
      [ "Requirements", "srs_qxk.html#srs_qxk-req", null ]
    ] ],
    [ "Quality Attributes", "srs_qa.html", [
      [ "Compliance with Standards", "srs_qa.html#srs_qa-std", null ],
      [ "Software Quality Attributes", "srs_qa.html#srs_qa-quality", null ],
      [ "Performance Requirements", "srs_qa.html#srs_qa-perform", null ],
      [ "Portability Requirements", "srs_qa.html#srs_qa-port", null ],
      [ "Ease of Development Requirements", "srs_qa.html#srs_qa-develop", [
        [ "REQ-QP-09_01", "srs_qa.html#REQ-QP-09_01", null ],
        [ "REQ-QP-09_02", "srs_qa.html#REQ-QP-09_02", null ],
        [ "REQ-QP-09_03", "srs_qa.html#REQ-QP-09_03", null ]
      ] ]
    ] ]
];