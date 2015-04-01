unit libdb;
interface
function db_create: integer; stdcall;
function db_env_create: integer; stdcall;
function db_sequence_create: integer; stdcall;
function db_strerror: integer; stdcall;
function db_version: integer; stdcall;
function db_xa_switch: integer; stdcall;
function log_compare: integer; stdcall;
function db_env_set_func_close: integer; stdcall;
function db_env_set_func_dirfree: integer; stdcall;
function db_env_set_func_dirlist: integer; stdcall;
function db_env_set_func_exists: integer; stdcall;
function db_env_set_func_free: integer; stdcall;
function db_env_set_func_fsync: integer; stdcall;
function db_env_set_func_ftruncate: integer; stdcall;
function db_env_set_func_ioinfo: integer; stdcall;
function db_env_set_func_malloc: integer; stdcall;
function db_env_set_func_map: integer; stdcall;
function db_env_set_func_open: integer; stdcall;
function db_env_set_func_pread: integer; stdcall;
function db_env_set_func_pwrite: integer; stdcall;
function db_env_set_func_read: integer; stdcall;
function db_env_set_func_realloc: integer; stdcall;
function db_env_set_func_rename: integer; stdcall;
function db_env_set_func_seek: integer; stdcall;
function db_env_set_func_sleep: integer; stdcall;
function db_env_set_func_unlink: integer; stdcall;
function db_env_set_func_unmap: integer; stdcall;
function db_env_set_func_write: integer; stdcall;
function db_env_set_func_yield: integer; stdcall;
function __db_add_recovery: integer; stdcall;
function __db_dbm_close: integer; stdcall;
function __db_dbm_delete: integer; stdcall;
function __db_dbm_fetch: integer; stdcall;
function __db_dbm_firstkey: integer; stdcall;
function __db_dbm_init: integer; stdcall;
function __db_dbm_nextkey: integer; stdcall;
function __db_dbm_store: integer; stdcall;
function __db_get_flags_fn: integer; stdcall;
function __db_get_seq_flags_fn: integer; stdcall;
function __db_hcreate: integer; stdcall;
function __db_hdestroy: integer; stdcall;
function __db_hsearch: integer; stdcall;
function __db_loadme: integer; stdcall;
function __db_ndbm_clearerr: integer; stdcall;
function __db_ndbm_close: integer; stdcall;
function __db_ndbm_delete: integer; stdcall;
function __db_ndbm_dirfno: integer; stdcall;
function __db_ndbm_error: integer; stdcall;
function __db_ndbm_fetch: integer; stdcall;
function __db_ndbm_firstkey: integer; stdcall;
function __db_ndbm_nextkey: integer; stdcall;
function __db_ndbm_open: integer; stdcall;
function __db_ndbm_pagfno: integer; stdcall;
function __db_ndbm_rdonly: integer; stdcall;
function __db_ndbm_store: integer; stdcall;
function __db_panic: integer; stdcall;
function __db_r_attach: integer; stdcall;
function __db_r_detach: integer; stdcall;
function __db_win32_mutex_init: integer; stdcall;
function __db_win32_mutex_lock: integer; stdcall;
function __db_win32_mutex_unlock: integer; stdcall;
function __ham_func2: integer; stdcall;
function __ham_func3: integer; stdcall;
function __ham_func4: integer; stdcall;
function __ham_func5: integer; stdcall;
function __ham_test: integer; stdcall;
function __lock_id_set: integer; stdcall;
function __os_calloc: integer; stdcall;
function __os_closehandle: integer; stdcall;
function __os_free: integer; stdcall;
function __os_ioinfo: integer; stdcall;
function __os_malloc: integer; stdcall;
function __os_open: integer; stdcall;
function __os_openhandle: integer; stdcall;
function __os_read: integer; stdcall;
function __os_realloc: integer; stdcall;
function __os_strdup: integer; stdcall;
function __os_umalloc: integer; stdcall;
function __os_write: integer; stdcall;
function __txn_id_set: integer; stdcall;
function __bam_adj_read: integer; stdcall;
function __bam_cadjust_read: integer; stdcall;
function __bam_cdel_read: integer; stdcall;
function __bam_curadj_read: integer; stdcall;
function __bam_pgin: integer; stdcall;
function __bam_pgout: integer; stdcall;
function __bam_rcuradj_read: integer; stdcall;
function __bam_relink_read: integer; stdcall;
function __bam_repl_read: integer; stdcall;
function __bam_root_read: integer; stdcall;
function __bam_rsplit_read: integer; stdcall;
function __bam_split_read: integer; stdcall;
function __crdel_metasub_read: integer; stdcall;
function __db_addrem_read: integer; stdcall;
function __db_big_read: integer; stdcall;
function __db_cksum_read: integer; stdcall;
function __db_debug_read: integer; stdcall;
function __db_dispatch: integer; stdcall;
function __db_dumptree: integer; stdcall;
function __db_err: integer; stdcall;
function __db_fileid_reset: integer; stdcall;
function __db_getlong: integer; stdcall;
function __db_getulong: integer; stdcall;
function __db_global_values: integer; stdcall;
function __db_isbigendian: integer; stdcall;
function __db_lsn_reset: integer; stdcall;
function __db_noop_read: integer; stdcall;
function __db_omode: integer; stdcall;
function __db_overwrite: integer; stdcall;
function __db_ovref_read: integer; stdcall;
function __db_pg_alloc_read: integer; stdcall;
function __db_pg_free_read: integer; stdcall;
function __db_pg_freedata_read: integer; stdcall;
function __db_pg_init_read: integer; stdcall;
function __db_pg_new_read: integer; stdcall;
function __db_pg_prepare_read: integer; stdcall;
function __db_pgin: integer; stdcall;
function __db_pgout: integer; stdcall;
function __db_pr_callback: integer; stdcall;
function __db_rpath: integer; stdcall;
function __db_stat_pp: integer; stdcall;
function __db_stat_print_pp: integer; stdcall;
function __db_util_cache: integer; stdcall;
function __db_util_interrupted: integer; stdcall;
function __db_util_logset: integer; stdcall;
function __db_util_siginit: integer; stdcall;
function __db_util_sigresend: integer; stdcall;
function __db_verify_internal: integer; stdcall;
function __dbreg_register_read: integer; stdcall;
function __fop_create_read: integer; stdcall;
function __fop_file_remove_read: integer; stdcall;
function __fop_remove_read: integer; stdcall;
function __fop_rename_read: integer; stdcall;
function __fop_write_read: integer; stdcall;
function __ham_chgpg_read: integer; stdcall;
function __ham_copypage_read: integer; stdcall;
function __ham_curadj_read: integer; stdcall;
function __ham_get_meta: integer; stdcall;
function __ham_groupalloc_read: integer; stdcall;
function __ham_insdel_read: integer; stdcall;
function __ham_metagroup_read: integer; stdcall;
function __ham_newpage_read: integer; stdcall;
function __ham_pgin: integer; stdcall;
function __ham_pgout: integer; stdcall;
function __ham_release_meta: integer; stdcall;
function __ham_replace_read: integer; stdcall;
function __ham_splitdata_read: integer; stdcall;
function __lock_list_print: integer; stdcall;
function __log_stat_pp: integer; stdcall;
function __os_clock: integer; stdcall;
function __os_get_errno: integer; stdcall;
function __os_id: integer; stdcall;
function __os_set_errno: integer; stdcall;
function __os_sleep: integer; stdcall;
function __os_ufree: integer; stdcall;
function __os_yield: integer; stdcall;
function __qam_add_read: integer; stdcall;
function __qam_del_read: integer; stdcall;
function __qam_delext_read: integer; stdcall;
function __qam_incfirst_read: integer; stdcall;
function __qam_mvptr_read: integer; stdcall;
function __qam_pgin_out: integer; stdcall;
function __rep_stat_print: integer; stdcall;
function __txn_child_read: integer; stdcall;
function __txn_ckp_read: integer; stdcall;
function __txn_recycle_read: integer; stdcall;
function __txn_regop_read: integer; stdcall;
function __txn_xa_regop_read: integer; stdcall;

implementation
const
  libdb43 = 'libdb43.dll';

function db_create; external libdb43 name 'db_create'; // index @1
function db_env_create; external libdb43 name 'db_env_create'; // index @2
function db_sequence_create; external libdb43 name 'db_sequence_create'; // index @3
function db_strerror; external libdb43 name 'db_strerror'; // index @4
function db_version; external libdb43 name 'db_version'; // index @5
function db_xa_switch; external libdb43 name 'db_xa_switch'; // index @6
function log_compare; external libdb43 name 'log_compare'; // index @7
function db_env_set_func_close; external libdb43 name 'db_env_set_func_close'; // index @8
function db_env_set_func_dirfree; external libdb43 name 'db_env_set_func_dirfree'; // index @9
function db_env_set_func_dirlist; external libdb43 name 'db_env_set_func_dirlist'; // index @10
function db_env_set_func_exists; external libdb43 name 'db_env_set_func_exists'; // index @11
function db_env_set_func_free; external libdb43 name 'db_env_set_func_free'; // index @12
function db_env_set_func_fsync; external libdb43 name 'db_env_set_func_fsync'; // index @13
function db_env_set_func_ftruncate; external libdb43 name 'db_env_set_func_ftruncate'; // index @14
function db_env_set_func_ioinfo; external libdb43 name 'db_env_set_func_ioinfo'; // index @15
function db_env_set_func_malloc; external libdb43 name 'db_env_set_func_malloc'; // index @16
function db_env_set_func_map; external libdb43 name 'db_env_set_func_map'; // index @17
function db_env_set_func_open; external libdb43 name 'db_env_set_func_open'; // index @18
function db_env_set_func_pread; external libdb43 name 'db_env_set_func_pread'; // index @19
function db_env_set_func_pwrite; external libdb43 name 'db_env_set_func_pwrite'; // index @20
function db_env_set_func_read; external libdb43 name 'db_env_set_func_read'; // index @21
function db_env_set_func_realloc; external libdb43 name 'db_env_set_func_realloc'; // index @22
function db_env_set_func_rename; external libdb43 name 'db_env_set_func_rename'; // index @23
function db_env_set_func_seek; external libdb43 name 'db_env_set_func_seek'; // index @24
function db_env_set_func_sleep; external libdb43 name 'db_env_set_func_sleep'; // index @25
function db_env_set_func_unlink; external libdb43 name 'db_env_set_func_unlink'; // index @26
function db_env_set_func_unmap; external libdb43 name 'db_env_set_func_unmap'; // index @27
function db_env_set_func_write; external libdb43 name 'db_env_set_func_write'; // index @28
function db_env_set_func_yield; external libdb43 name 'db_env_set_func_yield'; // index @29
function __db_add_recovery; external libdb43 name '__db_add_recovery'; // index @30
function __db_dbm_close; external libdb43 name '__db_dbm_close'; // index @31
function __db_dbm_delete; external libdb43 name '__db_dbm_delete'; // index @32
function __db_dbm_fetch; external libdb43 name '__db_dbm_fetch'; // index @33
function __db_dbm_firstkey; external libdb43 name '__db_dbm_firstkey'; // index @34
function __db_dbm_init; external libdb43 name '__db_dbm_init'; // index @35
function __db_dbm_nextkey; external libdb43 name '__db_dbm_nextkey'; // index @36
function __db_dbm_store; external libdb43 name '__db_dbm_store'; // index @37
function __db_get_flags_fn; external libdb43 name '__db_get_flags_fn'; // index @38
function __db_get_seq_flags_fn; external libdb43 name '__db_get_seq_flags_fn'; // index @39
function __db_hcreate; external libdb43 name '__db_hcreate'; // index @40
function __db_hdestroy; external libdb43 name '__db_hdestroy'; // index @41
function __db_hsearch; external libdb43 name '__db_hsearch'; // index @42
function __db_loadme; external libdb43 name '__db_loadme'; // index @43
function __db_ndbm_clearerr; external libdb43 name '__db_ndbm_clearerr'; // index @44
function __db_ndbm_close; external libdb43 name '__db_ndbm_close'; // index @45
function __db_ndbm_delete; external libdb43 name '__db_ndbm_delete'; // index @46
function __db_ndbm_dirfno; external libdb43 name '__db_ndbm_dirfno'; // index @47
function __db_ndbm_error; external libdb43 name '__db_ndbm_error'; // index @48
function __db_ndbm_fetch; external libdb43 name '__db_ndbm_fetch'; // index @49
function __db_ndbm_firstkey; external libdb43 name '__db_ndbm_firstkey'; // index @50
function __db_ndbm_nextkey; external libdb43 name '__db_ndbm_nextkey'; // index @51
function __db_ndbm_open; external libdb43 name '__db_ndbm_open'; // index @52
function __db_ndbm_pagfno; external libdb43 name '__db_ndbm_pagfno'; // index @53
function __db_ndbm_rdonly; external libdb43 name '__db_ndbm_rdonly'; // index @54
function __db_ndbm_store; external libdb43 name '__db_ndbm_store'; // index @55
function __db_panic; external libdb43 name '__db_panic'; // index @56
function __db_r_attach; external libdb43 name '__db_r_attach'; // index @57
function __db_r_detach; external libdb43 name '__db_r_detach'; // index @58
function __db_win32_mutex_init; external libdb43 name '__db_win32_mutex_init'; // index @59
function __db_win32_mutex_lock; external libdb43 name '__db_win32_mutex_lock'; // index @60
function __db_win32_mutex_unlock; external libdb43 name '__db_win32_mutex_unlock'; // index @61
function __ham_func2; external libdb43 name '__ham_func2'; // index @62
function __ham_func3; external libdb43 name '__ham_func3'; // index @63
function __ham_func4; external libdb43 name '__ham_func4'; // index @64
function __ham_func5; external libdb43 name '__ham_func5'; // index @65
function __ham_test; external libdb43 name '__ham_test'; // index @66
function __lock_id_set; external libdb43 name '__lock_id_set'; // index @67
function __os_calloc; external libdb43 name '__os_calloc'; // index @68
function __os_closehandle; external libdb43 name '__os_closehandle'; // index @69
function __os_free; external libdb43 name '__os_free'; // index @70
function __os_ioinfo; external libdb43 name '__os_ioinfo'; // index @71
function __os_malloc; external libdb43 name '__os_malloc'; // index @72
function __os_open; external libdb43 name '__os_open'; // index @73
function __os_openhandle; external libdb43 name '__os_openhandle'; // index @74
function __os_read; external libdb43 name '__os_read'; // index @75
function __os_realloc; external libdb43 name '__os_realloc'; // index @76
function __os_strdup; external libdb43 name '__os_strdup'; // index @77
function __os_umalloc; external libdb43 name '__os_umalloc'; // index @78
function __os_write; external libdb43 name '__os_write'; // index @79
function __txn_id_set; external libdb43 name '__txn_id_set'; // index @80
function __bam_adj_read; external libdb43 name '__bam_adj_read'; // index @81
function __bam_cadjust_read; external libdb43 name '__bam_cadjust_read'; // index @82
function __bam_cdel_read; external libdb43 name '__bam_cdel_read'; // index @83
function __bam_curadj_read; external libdb43 name '__bam_curadj_read'; // index @84
function __bam_pgin; external libdb43 name '__bam_pgin'; // index @85
function __bam_pgout; external libdb43 name '__bam_pgout'; // index @86
function __bam_rcuradj_read; external libdb43 name '__bam_rcuradj_read'; // index @87
function __bam_relink_read; external libdb43 name '__bam_relink_read'; // index @88
function __bam_repl_read; external libdb43 name '__bam_repl_read'; // index @89
function __bam_root_read; external libdb43 name '__bam_root_read'; // index @90
function __bam_rsplit_read; external libdb43 name '__bam_rsplit_read'; // index @91
function __bam_split_read; external libdb43 name '__bam_split_read'; // index @92
function __crdel_metasub_read; external libdb43 name '__crdel_metasub_read'; // index @93
function __db_addrem_read; external libdb43 name '__db_addrem_read'; // index @94
function __db_big_read; external libdb43 name '__db_big_read'; // index @95
function __db_cksum_read; external libdb43 name '__db_cksum_read'; // index @96
function __db_debug_read; external libdb43 name '__db_debug_read'; // index @97
function __db_dispatch; external libdb43 name '__db_dispatch'; // index @98
function __db_dumptree; external libdb43 name '__db_dumptree'; // index @99
function __db_err; external libdb43 name '__db_err'; // index @100
function __db_fileid_reset; external libdb43 name '__db_fileid_reset'; // index @101
function __db_getlong; external libdb43 name '__db_getlong'; // index @102
function __db_getulong; external libdb43 name '__db_getulong'; // index @103
function __db_global_values; external libdb43 name '__db_global_values'; // index @104
function __db_isbigendian; external libdb43 name '__db_isbigendian'; // index @105
function __db_lsn_reset; external libdb43 name '__db_lsn_reset'; // index @106
function __db_noop_read; external libdb43 name '__db_noop_read'; // index @107
function __db_omode; external libdb43 name '__db_omode'; // index @108
function __db_overwrite; external libdb43 name '__db_overwrite'; // index @109
function __db_ovref_read; external libdb43 name '__db_ovref_read'; // index @110
function __db_pg_alloc_read; external libdb43 name '__db_pg_alloc_read'; // index @111
function __db_pg_free_read; external libdb43 name '__db_pg_free_read'; // index @112
function __db_pg_freedata_read; external libdb43 name '__db_pg_freedata_read'; // index @113
function __db_pg_init_read; external libdb43 name '__db_pg_init_read'; // index @114
function __db_pg_new_read; external libdb43 name '__db_pg_new_read'; // index @115
function __db_pg_prepare_read; external libdb43 name '__db_pg_prepare_read'; // index @116
function __db_pgin; external libdb43 name '__db_pgin'; // index @117
function __db_pgout; external libdb43 name '__db_pgout'; // index @118
function __db_pr_callback; external libdb43 name '__db_pr_callback'; // index @119
function __db_rpath; external libdb43 name '__db_rpath'; // index @120
function __db_stat_pp; external libdb43 name '__db_stat_pp'; // index @121
function __db_stat_print_pp; external libdb43 name '__db_stat_print_pp'; // index @122
function __db_util_cache; external libdb43 name '__db_util_cache'; // index @123
function __db_util_interrupted; external libdb43 name '__db_util_interrupted'; // index @124
function __db_util_logset; external libdb43 name '__db_util_logset'; // index @125
function __db_util_siginit; external libdb43 name '__db_util_siginit'; // index @126
function __db_util_sigresend; external libdb43 name '__db_util_sigresend'; // index @127
function __db_verify_internal; external libdb43 name '__db_verify_internal'; // index @128
function __dbreg_register_read; external libdb43 name '__dbreg_register_read'; // index @129
function __fop_create_read; external libdb43 name '__fop_create_read'; // index @130
function __fop_file_remove_read; external libdb43 name '__fop_file_remove_read'; // index @131
function __fop_remove_read; external libdb43 name '__fop_remove_read'; // index @132
function __fop_rename_read; external libdb43 name '__fop_rename_read'; // index @133
function __fop_write_read; external libdb43 name '__fop_write_read'; // index @134
function __ham_chgpg_read; external libdb43 name '__ham_chgpg_read'; // index @135
function __ham_copypage_read; external libdb43 name '__ham_copypage_read'; // index @136
function __ham_curadj_read; external libdb43 name '__ham_curadj_read'; // index @137
function __ham_get_meta; external libdb43 name '__ham_get_meta'; // index @138
function __ham_groupalloc_read; external libdb43 name '__ham_groupalloc_read'; // index @139
function __ham_insdel_read; external libdb43 name '__ham_insdel_read'; // index @140
function __ham_metagroup_read; external libdb43 name '__ham_metagroup_read'; // index @141
function __ham_newpage_read; external libdb43 name '__ham_newpage_read'; // index @142
function __ham_pgin; external libdb43 name '__ham_pgin'; // index @143
function __ham_pgout; external libdb43 name '__ham_pgout'; // index @144
function __ham_release_meta; external libdb43 name '__ham_release_meta'; // index @145
function __ham_replace_read; external libdb43 name '__ham_replace_read'; // index @146
function __ham_splitdata_read; external libdb43 name '__ham_splitdata_read'; // index @147
function __lock_list_print; external libdb43 name '__lock_list_print'; // index @148
function __log_stat_pp; external libdb43 name '__log_stat_pp'; // index @149
function __os_clock; external libdb43 name '__os_clock'; // index @150
function __os_get_errno; external libdb43 name '__os_get_errno'; // index @151
function __os_id; external libdb43 name '__os_id'; // index @152
function __os_set_errno; external libdb43 name '__os_set_errno'; // index @153
function __os_sleep; external libdb43 name '__os_sleep'; // index @154
function __os_ufree; external libdb43 name '__os_ufree'; // index @155
function __os_yield; external libdb43 name '__os_yield'; // index @156
function __qam_add_read; external libdb43 name '__qam_add_read'; // index @157
function __qam_del_read; external libdb43 name '__qam_del_read'; // index @158
function __qam_delext_read; external libdb43 name '__qam_delext_read'; // index @159
function __qam_incfirst_read; external libdb43 name '__qam_incfirst_read'; // index @160
function __qam_mvptr_read; external libdb43 name '__qam_mvptr_read'; // index @161
function __qam_pgin_out; external libdb43 name '__qam_pgin_out'; // index @162
function __rep_stat_print; external libdb43 name '__rep_stat_print'; // index @163
function __txn_child_read; external libdb43 name '__txn_child_read'; // index @164
function __txn_ckp_read; external libdb43 name '__txn_ckp_read'; // index @165
function __txn_recycle_read; external libdb43 name '__txn_recycle_read'; // index @166
function __txn_regop_read; external libdb43 name '__txn_regop_read'; // index @167
function __txn_xa_regop_read; external libdb43 name '__txn_xa_regop_read'; // index @168

end.


