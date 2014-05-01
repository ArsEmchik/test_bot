class AddContenttextToPoems < ActiveRecord::Migration
  def change
    add_column :poems, :content_text, :tsvector
    execute "CREATE INDEX content_text_index ON Poems USING GIN(content_text)"
    execute "CREATE TRIGGER TS_content_text
              BEFORE INSERT OR UPDATE ON Poems
              FOR EACH ROW EXECUTE PROCEDURE
              tsvector_update_trigger(content_text,'pg_catalog.russian',content);"
  end
end
