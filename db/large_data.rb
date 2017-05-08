require_relative 'seed_helper'
number_of_products                               =2
number_of_platforms_per_product                  =3
number_of_test_metadatum_per_platform            =10
number_of_test_suite_records_per_test_metadatum  =15
number_of_test_case_records_per_test_suite_record=50

Seed::Helper.create_seed_data(number_of_products, number_of_platforms_per_product, number_of_test_metadatum_per_platform, number_of_test_suite_records_per_test_metadatum, number_of_test_case_records_per_test_suite_record)