/// SQLite DDL aligned with upstream CherryTree [CtStorageSqlite] (see cherrytree/src/ct/ct_storage_sqlite.cc).
abstract final class CtbSchema {
  static const String tableNodeCreate = '''
CREATE TABLE node (
  node_id INTEGER UNIQUE,
  name TEXT,
  txt TEXT,
  syntax TEXT,
  tags TEXT,
  is_ro INTEGER,
  is_richtxt INTEGER,
  has_codebox INTEGER,
  has_table INTEGER,
  has_image INTEGER,
  level INTEGER,
  ts_creation INTEGER,
  ts_lastsave INTEGER
)''';

  static const String tableCodeboxCreate = '''
CREATE TABLE codebox (
  node_id INTEGER,
  offset INTEGER,
  justification TEXT,
  txt TEXT,
  syntax TEXT,
  width INTEGER,
  height INTEGER,
  is_width_pix INTEGER,
  do_highl_bra INTEGER,
  do_show_linenum INTEGER
)''';

  static const String tableGridCreate = '''
CREATE TABLE grid (
  node_id INTEGER,
  offset INTEGER,
  justification TEXT,
  txt TEXT,
  col_min INTEGER,
  col_max INTEGER
)''';

  static const String tableImageCreate = '''
CREATE TABLE image (
  node_id INTEGER,
  offset INTEGER,
  justification TEXT,
  anchor TEXT,
  png BLOB,
  filename TEXT,
  link TEXT,
  time INTEGER
)''';

  static const String tableChildrenCreate = '''
CREATE TABLE children (
  node_id INTEGER UNIQUE,
  father_id INTEGER,
  sequence INTEGER,
  master_id INTEGER
)''';

  static const String tableBookmarkCreate = '''
CREATE TABLE bookmark (
  node_id INTEGER UNIQUE,
  sequence INTEGER
)''';

  static const List<String> createAll = [
    tableNodeCreate,
    tableCodeboxCreate,
    tableGridCreate,
    tableImageCreate,
    tableChildrenCreate,
    tableBookmarkCreate,
  ];
}
