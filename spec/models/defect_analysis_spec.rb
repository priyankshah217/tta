require "rspec"

describe DefectAnalysis do

  it "should return json if platform_id passed" do
    platform = FactoryGirl.create(:platform)
    json     =DefectAnalysis.new.get_result_json(platform.id, "2013-02-19".to_date, "ALL")
    json.should_not be_nil
  end

  it "should throw error when platform_id is nil" do
    expect { DefectAnalysis.new.get_result_json(nil, "2013-02-19".to_date, "ALL") }.to raise_error
  end

  it "should throw error when analysis_date is nil" do
    expect { DefectAnalysis.new.get_result_json("1", nil, "ALL") }.to raise_error
  end

  it "should return json with proper data" do
    product           = FactoryGirl.create(:product)
    platform          = FactoryGirl.create(:platform, :product_id => product.id)
    test_metadata     = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :branch => "master")
    test_suite_record = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata.id)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id)
    json = DefectAnalysis.new.get_result_json(platform.id, "2013-02-20".to_date, "ALL")
    json.should eq("{\"platform_name\":\"TTA_PLATFORM\",\"errors\":{\"UNIT TEST\":[{\"ERROR_MSG\":[\"Class_01\"]}]},\"percentage\":[\"100.00\"]}")
  end

  it "should not repeat the error message on uploading test cases with same error message" do
    product           = FactoryGirl.create(:product)
    platform          = FactoryGirl.create(:platform, :product_id => product.id)
    test_metadata     = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :branch => "master")
    test_suite_record = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata.id, :number_of_errors => 3)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :time_taken => 1, :class_name => "class1.1.1")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :time_taken => 1, :class_name => "class1.1.2")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :time_taken => 1, :class_name => "class1.1.3")
    json        = DefectAnalysis.new.get_result_json(platform.id, "2013-02-20".to_date, "ALL")
    parsed_json = ActiveSupport::JSON.decode(json)
    parsed_json["errors"]["UNIT TEST"].first["ERROR_MSG"].should =~ ["class1.1.1", "class1.1.2", "class1.1.3"]
  end

  it "should give appropriate percentages for the tests uploaded" do
    product           = FactoryGirl.create(:product)
    platform          = FactoryGirl.create(:platform, :product_id => product.id)
    test_metadata     = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :branch => "master")
    test_suite_record = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata.id, :number_of_errors => 6)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.1.1")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.1.2")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.1.3")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.1.4")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.2.1", :error_msg => "ERROR_MSG1")
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record.id, :class_name => "class1.2.2", :error_msg => "ERROR_MSG1")
    json        = DefectAnalysis.new.get_result_json(platform.id, "2013-02-20".to_date, "ALL")
    parsed_json = ActiveSupport::JSON.decode(json)
    parsed_json["percentage"].should =~ ["66.67", "33.33"]
  end

  it "should categorize the error messages w.r.t their test categories" do
    product  = FactoryGirl.create(:product)
    platform = FactoryGirl.create(:platform, :product_id => product.id)

    test_metadata_1 = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :branch => "master")
    test_metadata_2 = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :test_category => "FUNCTIONAL TEST", :branch => "master")
    test_metadata_3 = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :test_category => "INTEGRATION TEST", :branch => "master")

    test_suite_record_1 = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata_1.id)
    test_suite_record_2 = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata_2.id)
    test_suite_record_3 = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata_3.id)

    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record_1.id)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record_2.id)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record_3.id)
    json        = DefectAnalysis.new.get_result_json(platform.id, "2013-02-20".to_date, "ALL")
    parsed_json = ActiveSupport::JSON.decode(json)
    parsed_json["errors"].should eq({ "UNIT TEST" => [{ "ERROR_MSG" => ["Class_01"] }], "FUNCTIONAL TEST" => [{ "ERROR_MSG" => ["Class_01"] }], "INTEGRATION TEST" => [{ "ERROR_MSG" => ["Class_01"] }] })
  end

  it "should not display errors of a particular type in some other test category" do
    product  = FactoryGirl.create(:product)
    platform = FactoryGirl.create(:platform, :product_id => product.id)

    test_metadata_1 = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :branch => "master")
    test_metadata_2 = FactoryGirl.create(:test_metadatum, :platform_id => platform.id, :test_category => "FUNCTIONAL TEST", :branch => "master")

    test_suite_record_1 = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata_1.id)
    test_suite_record_2 = FactoryGirl.create(:test_suite_records, :test_metadatum_id => test_metadata_2.id)

    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record_1.id)
    FactoryGirl.create(:test_case_record, :test_suite_record_id => test_suite_record_2.id, :error_msg => "", :class_name => "")

    json        = DefectAnalysis.new.get_result_json(platform.id, "2013-02-20".to_date, "FUNCTIONAL TEST")
    parsed_json = ActiveSupport::JSON.decode(json)
    parsed_json["errors"]["FUNCTIONAL TEST"].should_not eq [{ "ERROR_MSG" => ["Class_01"] }]
  end
end