require 'xmlsimple'
require 'zip/zipfilesystem'
require 'ftools'


class UploadController < ApplicationController


  def create

    project = Project.find_or_create_by_name(params[:project_name])
    sub_project = project.sub_projects.find_or_create_by_name(params[:sub_project_name])

    meta_datum = sub_project.test_metadatum.find_or_create_by_ci_job_name_and_browser_and_type_of_environment_and_host_name_and_os_name_and_test_category_and_test_report_type(params[:ci_job_name],
                  params[:browser],params[:type_of_environment],params[:host_name],params[:os_name],params[:test_category],params[:test_report_type])

    meta_datum.date_of_execution= params[:date_of_execution]

    meta_datum.save!

    tmp = params[:myFile].tempfile
    file = File.join("public", params[:myFile].original_filename)
    FileUtils.cp tmp.path, file
    Zip::ZipFile.open(file) do |zipfile|
        zipfile.each do |entry|
        p tempp=entry.to_s
        contents = zipfile.read(entry)
        contents_string= contents.to_s
        if tempp =~ /\.xml$/
          if contents_string.start_with? ("<?xml")
            parse_xml(contents, meta_datum.id)
          end
        end
      end
    end

    redirect_to :action => :show, :project_id => project.id, :sub_project_id => sub_project.id, :project_meta_id => meta_datum.id
  end

  def show
    @project = Project.find(params[:project_id])
    @sub_project= @project.sub_projects.find(params[:sub_project_id])
    @project_meta = @sub_project.test_metadatum.find(params[:project_meta_id])
    begin
      respond_to do |format|
        format.html #show.html.erb
        format.json { render json: @project }
      end
    end
  end

  def parse_xml(config_xml, meta_id)
    config = XmlSimple.xml_in(config_xml, {'KeyAttr' => 'name'})
    @xml_data = TestRecord.new()
    @xml_data.test_metadatum_id=meta_id
    @xml_data.class_name= config['name']
    @xml_data.number_of_errors= config['errors']
    @xml_data.number_of_failures= config['failures']
    @xml_data.number_of_tests= config['tests']
    @xml_data.time_taken= config['time']
    @xml_data.save

  end

end
