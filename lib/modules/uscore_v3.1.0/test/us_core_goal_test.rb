# frozen_string_literal: true

# NOTE: This is a generated file. Any changes made to this file will be
#       overwritten when it is regenerated

require_relative '../../../../test/test_helper'

describe Inferno::Sequence::USCore310GoalSequence do
  before do
    @sequence_class = Inferno::Sequence::USCore310GoalSequence
    @base_url = 'http://www.example.com/fhir'
    @token = 'ABC'
    @instance = Inferno::Models::TestingInstance.create(url: @base_url, token: @token, selected_module: 'uscore_v3.1.0')
    @client = FHIR::Client.for_testing_instance(@instance)
    @patient_id = 'example'
    @instance.patient_id = @patient_id
    set_resource_support(@instance, 'Goal')
    @auth_header = { 'Authorization' => "Bearer #{@token}" }
  end

  describe 'Goal search by patient test' do
    before do
      @test = @sequence_class[:search_by_patient]
      @sequence = @sequence_class.new(@instance, @client)
      @goal = FHIR.from_contents(load_fixture(:us_core_goal))
      @goal_ary = [@goal]
      @sequence.instance_variable_set(:'@goal', @goal)
      @sequence.instance_variable_set(:'@goal_ary', @goal_ary)

      @query = {
        'patient': 'patient'
      }
    end

    it 'fails if a non-success response code is received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 401)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Bad response code: expected 200, 201, but found 401. ', exception.message
    end

    it 'fails if a Bundle is not received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: FHIR::Goal.new.to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Expected FHIR Bundle but found: Goal', exception.message
    end

    it 'skips if an empty Bundle is received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: FHIR::Bundle.new.to_json)

      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_equal 'No Goal resources appear to be available. Please use patients with more information.', exception.message
    end

    it 'fails if the bundle contains a resource which does not conform to the base FHIR spec' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: wrap_resources_in_bundle(FHIR::Goal.new(id: '!@#$%')).to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_match(/Invalid \w+:/, exception.message)
    end

    it 'succeeds when a bundle containing a valid resource matching the search parameters is returned' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: wrap_resources_in_bundle(@goal_ary).to_json)

      @sequence.run_test(@test)
    end

    describe 'with servers that require status' do
      it 'fails if a 400 is received without an OperationOutcome' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Server returned a status of 400 without an OperationOutcome.', exception.message
      end

      it 'warns if the search is not documented in the CapabilityStatement' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)

        assert_raises(WebMock::NetConnectNotAllowedError) { @sequence.run_test(@test) }

        warnings = @sequence.instance_variable_get(:@test_warnings)

        assert warnings.present?, 'Test did not generate any warnings.'
        assert warnings.any? { |warning| warning.match(/search interaction for this resource is not documented/) },
               'Test did not generate the expected warning.'
      end

      it 'fails if searching with status is not successful' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query.merge('lifecycle-status': ['proposed', 'planned', 'accepted', 'active', 'on-hold', 'completed', 'cancelled', 'entered-in-error', 'rejected'].first), headers: @auth_header)
          .to_return(status: 500)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Bad response code: expected 200, 201, but found 500. ', exception.message
      end

      it 'fails if searching with status does not return a Bundle' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query.merge('lifecycle-status': ['proposed', 'planned', 'accepted', 'active', 'on-hold', 'completed', 'cancelled', 'entered-in-error', 'rejected'].first), headers: @auth_header)
          .to_return(status: 200, body: FHIR::Goal.new.to_json)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Expected FHIR Bundle but found: Goal', exception.message
      end

      it 'succeeds if searching with status returns valid resources' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query.merge('lifecycle-status': ['proposed', 'planned', 'accepted', 'active', 'on-hold', 'completed', 'cancelled', 'entered-in-error', 'rejected'].first), headers: @auth_header)
          .to_return(status: 200, body: wrap_resources_in_bundle([@goal]).to_json)

        @sequence.run_test(@test)
      end
    end
  end

  describe 'Goal search by patient+target-date test' do
    before do
      @test = @sequence_class[:search_by_patient_target_date]
      @sequence = @sequence_class.new(@instance, @client)
      @goal = FHIR.from_contents(load_fixture(:us_core_goal))
      @goal_ary = [@goal]
      @sequence.instance_variable_set(:'@goal', @goal)
      @sequence.instance_variable_set(:'@goal_ary', @goal_ary)

      @sequence.instance_variable_set(:'@resources_found', true)

      @query = {
        'patient': 'patient',
        'target-date': @sequence.get_value_for_search_param(@sequence.resolve_element_from_path(@goal_ary, 'target.dueDate'))
      }
    end

    it 'skips if no Goal resources have been found' do
      @sequence.instance_variable_set(:'@resources_found', false)

      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_equal 'No Goal resources appear to be available. Please use patients with more information.', exception.message
    end

    it 'skips if a value for one of the search parameters cannot be found' do
      @sequence.instance_variable_set(:'@goal_ary', [FHIR::Goal.new])

      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_match(/Could not resolve [\w-]+ in given resource/, exception.message)
    end

    it 'fails if a non-success response code is received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 401)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Bad response code: expected 200, 201, but found 401. ', exception.message
    end

    it 'fails if a Bundle is not received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: FHIR::Goal.new.to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Expected FHIR Bundle but found: Goal', exception.message
    end

    it 'fails if the bundle contains a resource which does not conform to the base FHIR spec' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: wrap_resources_in_bundle(FHIR::Goal.new(id: '!@#$%')).to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_match(/Invalid \w+:/, exception.message)
    end

    describe 'with servers that require status' do
      it 'fails if a 400 is received without an OperationOutcome' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Server returned a status of 400 without an OperationOutcome.', exception.message
      end

      it 'warns if the search is not documented in the CapabilityStatement' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)

        assert_raises(WebMock::NetConnectNotAllowedError) { @sequence.run_test(@test) }

        warnings = @sequence.instance_variable_get(:@test_warnings)

        assert warnings.present?, 'Test did not generate any warnings.'
        assert warnings.any? { |warning| warning.match(/search interaction for this resource is not documented/) },
               'Test did not generate the expected warning.'
      end

      it 'fails if searching with status is not successful' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query.merge('lifecycle-status': ['proposed', 'planned', 'accepted', 'active', 'on-hold', 'completed', 'cancelled', 'entered-in-error', 'rejected'].first), headers: @auth_header)
          .to_return(status: 500)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Bad response code: expected 200, 201, but found 500. ', exception.message
      end

      it 'fails if searching with status does not return a Bundle' do
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query, headers: @auth_header)
          .to_return(status: 400, body: FHIR::OperationOutcome.new.to_json)
        stub_request(:get, "#{@base_url}/Goal")
          .with(query: @query.merge('lifecycle-status': ['proposed', 'planned', 'accepted', 'active', 'on-hold', 'completed', 'cancelled', 'entered-in-error', 'rejected'].first), headers: @auth_header)
          .to_return(status: 200, body: FHIR::Goal.new.to_json)

        exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

        assert_equal 'Expected FHIR Bundle but found: Goal', exception.message
      end
    end
  end

  describe 'Goal search by patient+lifecycle-status test' do
    before do
      @test = @sequence_class[:search_by_patient_lifecycle_status]
      @sequence = @sequence_class.new(@instance, @client)
      @goal = FHIR.from_contents(load_fixture(:us_core_goal))
      @goal_ary = [@goal]
      @sequence.instance_variable_set(:'@goal', @goal)
      @sequence.instance_variable_set(:'@goal_ary', @goal_ary)

      @sequence.instance_variable_set(:'@resources_found', true)

      @query = {
        'patient': 'patient',
        'lifecycle-status': @sequence.get_value_for_search_param(@sequence.resolve_element_from_path(@goal_ary, 'lifecycleStatus'))
      }
    end

    it 'skips if no Goal resources have been found' do
      @sequence.instance_variable_set(:'@resources_found', false)

      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_equal 'No Goal resources appear to be available. Please use patients with more information.', exception.message
    end

    it 'skips if a value for one of the search parameters cannot be found' do
      @sequence.instance_variable_set(:'@goal_ary', [FHIR::Goal.new])

      exception = assert_raises(Inferno::SkipException) { @sequence.run_test(@test) }

      assert_match(/Could not resolve [\w-]+ in given resource/, exception.message)
    end

    it 'fails if a non-success response code is received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 401)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Bad response code: expected 200, 201, but found 401. ', exception.message
    end

    it 'fails if a Bundle is not received' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: FHIR::Goal.new.to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_equal 'Expected FHIR Bundle but found: Goal', exception.message
    end

    it 'fails if the bundle contains a resource which does not conform to the base FHIR spec' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: wrap_resources_in_bundle(FHIR::Goal.new(id: '!@#$%')).to_json)

      exception = assert_raises(Inferno::AssertionException) { @sequence.run_test(@test) }

      assert_match(/Invalid \w+:/, exception.message)
    end

    it 'succeeds when a bundle containing a valid resource matching the search parameters is returned' do
      stub_request(:get, "#{@base_url}/Goal")
        .with(query: @query, headers: @auth_header)
        .to_return(status: 200, body: wrap_resources_in_bundle(@goal_ary).to_json)

      @sequence.run_test(@test)
    end
  end
end
