# frozen_string_literal: true

module Inferno
  module Sequence
    class USCore301PulseOximetrySequence < SequenceBase
      title 'Pulse Oximetry Tests'

      description 'Verify that Observation resources on the FHIR server follow the Argonaut Data Query Implementation Guide'

      test_id_prefix 'USCPO'

      requires :token, :patient_id
      conformance_supports :Observation

      def validate_resource_item(resource, property, value)
        case property

        when 'status'
          value_found = can_resolve_path(resource, 'status') { |value_in_resource| value_in_resource == value }
          assert value_found, 'status on resource does not match status requested'

        when 'category'
          value_found = can_resolve_path(resource, 'category.coding.code') { |value_in_resource| value_in_resource == value }
          assert value_found, 'category on resource does not match category requested'

        when 'code'
          value_found = can_resolve_path(resource, 'code.coding.code') { |value_in_resource| value_in_resource == value }
          assert value_found, 'code on resource does not match code requested'

        when 'date'
          value_found = can_resolve_path(resource, 'effectiveDateTime') do |date|
            validate_date_search(value, date)
          end
          assert value_found, 'date on resource does not match date requested'

        when 'patient'
          value_found = can_resolve_path(resource, 'subject.reference') { |reference| [value, 'Patient/' + value].include? reference }
          assert value_found, 'patient on resource does not match patient requested'

        end
      end

      details %(

        The #{title} Sequence tests `#{title.gsub(/\s+/, '')}` resources associated with the provided patient.

      )

      @resources_found = false

      test 'Server rejects Observation search without authorization' do
        metadata do
          id '01'
          link 'http://www.fhir.org/guides/argonaut/r2/Conformance-server.html'
          desc %(
          )
          versions :r4
        end

        @client.set_no_auth
        omit 'Do not test if no bearer token set' if @instance.token.blank?

        patient_val = @instance.patient_id
        code_val = resolve_element_from_path(@observation, 'code.coding.code')
        search_params = { 'patient': patient_val, 'code': code_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        @client.set_bearer_token(@instance.token)
        assert_response_unauthorized reply
      end

      test 'Server returns expected results from Observation search by patient+code' do
        metadata do
          id '02'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        patient_val = @instance.patient_id
        code_val = resolve_element_from_path(@observation, 'code.coding.code')
        search_params = { 'patient': patient_val, 'code': code_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        assert_response_ok(reply)
        assert_bundle_response(reply)

        resource_count = reply&.resource&.entry&.length || 0
        @resources_found = true if resource_count.positive?

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        @observation = reply.try(:resource).try(:entry).try(:first).try(:resource)
        @observation_ary = reply&.resource&.entry&.map { |entry| entry&.resource }
        save_resource_ids_in_bundle(versioned_resource_class('Observation'), reply)
        save_delayed_sequence_references(@observation)
        validate_search_reply(versioned_resource_class('Observation'), reply, search_params)
      end

      test 'Server returns expected results from Observation search by patient+category+date' do
        metadata do
          id '03'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        assert !@observation.nil?, 'Expected valid Observation resource to be present'

        patient_val = @instance.patient_id
        category_val = resolve_element_from_path(@observation, 'category.coding.code')
        date_val = resolve_element_from_path(@observation, 'effectiveDateTime')
        search_params = { 'patient': patient_val, 'category': category_val, 'date': date_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        validate_search_reply(versioned_resource_class('Observation'), reply, search_params)
        assert_response_ok(reply)
      end

      test 'Server returns expected results from Observation search by patient+category' do
        metadata do
          id '04'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        assert !@observation.nil?, 'Expected valid Observation resource to be present'

        patient_val = @instance.patient_id
        category_val = resolve_element_from_path(@observation, 'category.coding.code')
        search_params = { 'patient': patient_val, 'category': category_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        validate_search_reply(versioned_resource_class('Observation'), reply, search_params)
        assert_response_ok(reply)
      end

      test 'Server returns expected results from Observation search by patient+category+status' do
        metadata do
          id '05'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          optional
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        assert !@observation.nil?, 'Expected valid Observation resource to be present'

        patient_val = @instance.patient_id
        category_val = resolve_element_from_path(@observation, 'category.coding.code')
        status_val = resolve_element_from_path(@observation, 'status')
        search_params = { 'patient': patient_val, 'category': category_val, 'status': status_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        validate_search_reply(versioned_resource_class('Observation'), reply, search_params)
        assert_response_ok(reply)
      end

      test 'Server returns expected results from Observation search by patient+code+date' do
        metadata do
          id '06'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          optional
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        assert !@observation.nil?, 'Expected valid Observation resource to be present'

        patient_val = @instance.patient_id
        code_val = resolve_element_from_path(@observation, 'code.coding.code')
        date_val = resolve_element_from_path(@observation, 'effectiveDateTime')
        search_params = { 'patient': patient_val, 'code': code_val, 'date': date_val }
        search_params.each { |param, value| skip "Could not resolve #{param} in given resource" if value.nil? }

        reply = get_resource_by_params(versioned_resource_class('Observation'), search_params)
        validate_search_reply(versioned_resource_class('Observation'), reply, search_params)
        assert_response_ok(reply)
      end

      test 'Observation read resource supported' do
        metadata do
          id '07'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        skip_if_not_supported(:Observation, [:read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_read_reply(@observation, versioned_resource_class('Observation'))
      end

      test 'Observation vread resource supported' do
        metadata do
          id '08'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        skip_if_not_supported(:Observation, [:vread])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_vread_reply(@observation, versioned_resource_class('Observation'))
      end

      test 'Observation history resource supported' do
        metadata do
          id '09'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/CapabilityStatement-us-core-server.html'
          desc %(
          )
          versions :r4
        end

        skip_if_not_supported(:Observation, [:history])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_history_reply(@observation, versioned_resource_class('Observation'))
      end

      test 'Observation resources associated with Patient conform to US Core R4 profiles' do
        metadata do
          id '10'
          link 'http://hl7.org/fhir/us/core/StructureDefinition/us-core-pulse-oximetry'
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found
        test_resources_against_profile('Observation')
      end

      test 'At least one of every must support element is provided in any Observation for this patient.' do
        metadata do
          id '11'
          link 'https://build.fhir.org/ig/HL7/US-Core-R4/general-guidance.html/#must-support'
          desc %(
          )
          versions :r4
        end

        skip 'No resources appear to be available for this patient. Please use patients with more information' unless @observation_ary&.any?
        must_support_confirmed = {}
        must_support_elements = [
          'Observation.status',
          'Observation.category',
          'Observation.category',
          'Observation.category.coding',
          'Observation.category.coding.system',
          'Observation.category.coding.code',
          'Observation.code',
          'Observation.code.coding',
          'Observation.code.coding',
          'Observation.code.coding.system',
          'Observation.code.coding.code',
          'Observation.subject',
          'Observation.effectiveDateTime',
          'Observation.effectivePeriod',
          'Observation.valueQuantity',
          'Observation.valueQuantity.value',
          'Observation.valueQuantity.unit',
          'Observation.valueQuantity.system',
          'Observation.valueQuantity.code',
          'Observation.dataAbsentReason',
          'Observation.component',
          'Observation.component.code',
          'Observation.component.valueQuantity',
          'Observation.component.valueCodeableConcept',
          'Observation.component.valueString',
          'Observation.component.valueBoolean',
          'Observation.component.valueInteger',
          'Observation.component.valueRange',
          'Observation.component.valueRatio',
          'Observation.component.valueSampledData',
          'Observation.component.valueTime',
          'Observation.component.valueDateTime',
          'Observation.component.valuePeriod',
          'Observation.component.dataAbsentReason',
          'Observation.component',
          'Observation.component.code',
          'Observation.component.valueQuantity',
          'Observation.component.valueCodeableConcept',
          'Observation.component.valueString',
          'Observation.component.valueBoolean',
          'Observation.component.valueInteger',
          'Observation.component.valueRange',
          'Observation.component.valueRatio',
          'Observation.component.valueSampledData',
          'Observation.component.valueTime',
          'Observation.component.valueDateTime',
          'Observation.component.valuePeriod',
          'Observation.component.valueQuantity.value',
          'Observation.component.valueCodeableConcept.value',
          'Observation.component.valueString.value',
          'Observation.component.valueBoolean.value',
          'Observation.component.valueInteger.value',
          'Observation.component.valueRange.value',
          'Observation.component.valueRatio.value',
          'Observation.component.valueSampledData.value',
          'Observation.component.valueTime.value',
          'Observation.component.valueDateTime.value',
          'Observation.component.valuePeriod.value',
          'Observation.component.valueQuantity.unit',
          'Observation.component.valueCodeableConcept.unit',
          'Observation.component.valueString.unit',
          'Observation.component.valueBoolean.unit',
          'Observation.component.valueInteger.unit',
          'Observation.component.valueRange.unit',
          'Observation.component.valueRatio.unit',
          'Observation.component.valueSampledData.unit',
          'Observation.component.valueTime.unit',
          'Observation.component.valueDateTime.unit',
          'Observation.component.valuePeriod.unit',
          'Observation.component.valueQuantity.system',
          'Observation.component.valueCodeableConcept.system',
          'Observation.component.valueString.system',
          'Observation.component.valueBoolean.system',
          'Observation.component.valueInteger.system',
          'Observation.component.valueRange.system',
          'Observation.component.valueRatio.system',
          'Observation.component.valueSampledData.system',
          'Observation.component.valueTime.system',
          'Observation.component.valueDateTime.system',
          'Observation.component.valuePeriod.system',
          'Observation.component.valueQuantity.code',
          'Observation.component.valueCodeableConcept.code',
          'Observation.component.valueString.code',
          'Observation.component.valueBoolean.code',
          'Observation.component.valueInteger.code',
          'Observation.component.valueRange.code',
          'Observation.component.valueRatio.code',
          'Observation.component.valueSampledData.code',
          'Observation.component.valueTime.code',
          'Observation.component.valueDateTime.code',
          'Observation.component.valuePeriod.code',
          'Observation.component.dataAbsentReason',
          'Observation.component',
          'Observation.component.code',
          'Observation.component.valueQuantity',
          'Observation.component.valueCodeableConcept',
          'Observation.component.valueString',
          'Observation.component.valueBoolean',
          'Observation.component.valueInteger',
          'Observation.component.valueRange',
          'Observation.component.valueRatio',
          'Observation.component.valueSampledData',
          'Observation.component.valueTime',
          'Observation.component.valueDateTime',
          'Observation.component.valuePeriod',
          'Observation.component.valueQuantity.value',
          'Observation.component.valueCodeableConcept.value',
          'Observation.component.valueString.value',
          'Observation.component.valueBoolean.value',
          'Observation.component.valueInteger.value',
          'Observation.component.valueRange.value',
          'Observation.component.valueRatio.value',
          'Observation.component.valueSampledData.value',
          'Observation.component.valueTime.value',
          'Observation.component.valueDateTime.value',
          'Observation.component.valuePeriod.value',
          'Observation.component.valueQuantity.unit',
          'Observation.component.valueCodeableConcept.unit',
          'Observation.component.valueString.unit',
          'Observation.component.valueBoolean.unit',
          'Observation.component.valueInteger.unit',
          'Observation.component.valueRange.unit',
          'Observation.component.valueRatio.unit',
          'Observation.component.valueSampledData.unit',
          'Observation.component.valueTime.unit',
          'Observation.component.valueDateTime.unit',
          'Observation.component.valuePeriod.unit',
          'Observation.component.valueQuantity.system',
          'Observation.component.valueCodeableConcept.system',
          'Observation.component.valueString.system',
          'Observation.component.valueBoolean.system',
          'Observation.component.valueInteger.system',
          'Observation.component.valueRange.system',
          'Observation.component.valueRatio.system',
          'Observation.component.valueSampledData.system',
          'Observation.component.valueTime.system',
          'Observation.component.valueDateTime.system',
          'Observation.component.valuePeriod.system',
          'Observation.component.valueQuantity.code',
          'Observation.component.valueCodeableConcept.code',
          'Observation.component.valueString.code',
          'Observation.component.valueBoolean.code',
          'Observation.component.valueInteger.code',
          'Observation.component.valueRange.code',
          'Observation.component.valueRatio.code',
          'Observation.component.valueSampledData.code',
          'Observation.component.valueTime.code',
          'Observation.component.valueDateTime.code',
          'Observation.component.valuePeriod.code',
          'Observation.component.dataAbsentReason'
        ]
        must_support_elements.each do |path|
          @observation_ary&.each do |resource|
            truncated_path = path.gsub('Observation.', '')
            must_support_confirmed[path] = true if can_resolve_path(resource, truncated_path)
            break if must_support_confirmed[path]
          end
          resource_count = @observation_ary.length

          skip "Could not find #{path} in any of the #{resource_count} provided Observation resource(s)" unless must_support_confirmed[path]
        end
        @instance.save!
      end

      test 'All references can be resolved' do
        metadata do
          id '12'
          link 'https://www.hl7.org/fhir/DSTU2/references.html'
          desc %(
          )
          versions :r4
        end

        skip_if_not_supported(:Observation, [:search, :read])
        skip 'No resources appear to be available for this patient. Please use patients with more information.' unless @resources_found

        validate_reference_resolutions(@observation)
      end
    end
  end
end
