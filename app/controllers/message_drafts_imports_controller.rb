class MessageDraftsImportsController < ApplicationController
  def create
    authorize MessageDraftsImport

    file_storage = FileStorage.new

    zip_content = params[:content]
    import = MessageDraftsImport.create!(
      name: "#{Time.now.to_i}_#{zip_content.original_filename}",
      box: Current.box
    )

    import_path = file_storage.store("imports", import_path(import), zip_content.read.force_encoding("UTF-8"))
    Drafts::ParseImportJob.perform_later(import, import_path)

    redirect_to message_drafts_path
  end

  def upload_new
    @box = Current.box if Current.box
    @box = Current.tenant.boxes.first if Current.tenant.boxes.count == 1
    authorize MessageDraftsImport
  end

  private

  def import_path(import)
    File.join(String(Current.box.id), import.name)
  end
end