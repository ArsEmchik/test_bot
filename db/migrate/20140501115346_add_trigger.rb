class AddTrigger < ActiveRecord::Migration
  def change
    execute "CREATE INDEX content_text_GIN ON Rows USING GIN(content_text)"
    execute "CREATE TRIGGER TS_content_text
              BEFORE INSERT OR UPDATE ON Rows
              FOR EACH ROW EXECUTE PROCEDURE
              tsvector_update_trigger(content_text,'pg_catalog.russian',content);"
  end
end
