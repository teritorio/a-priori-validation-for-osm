# frozen_string_literal: true
# typed: true

require 'sorbet-runtime'
require 'test/unit'
require './validators'
require './time_machine'


class TestValidator < Test::Unit::TestCase
  extend T::Sig
  include Validators

  def test_simple
    id = 'foo'
    action = 'accept'
    validator = Validator.new(id:, action:)

    actions = T.let([], T::Array[Action])
    validator.assign_action(actions)

    assert_equal(1, actions.size)
    a = T.must(actions[0])
    assert_equal(id, a.validator_id)
    assert_equal(action, a.action)
  end

  def test_action_force
    id = 'foo'
    action = 'accept'
    validator = Validator.new(id:, action_force: action)
    puts validator.inspect

    actions = T.let([], T::Array[Action])
    validator.assign_action(actions)
    validator.assign_action(actions)

    assert_equal(1, actions.size)
    a = T.must(actions[0])
    assert_equal(id, a.validator_id)
    assert_equal(action, a.action)
  end
end

class TestUserList < Test::Unit::TestCase
  extend T::Sig
  include Validators

  def test_simple
    id = 'foo'
    action = 'accept'
    validator = UserList.new(id:, action:, list: ['bob'])
    validation_action = [Types::Action.new(
      validator_id: id,
      description: nil,
      action:,
    )]

    after = {
      'lat' => 0.0,
      'lon' => 0.0,
      'nodes' => nil,
      'deleted' => false,
      'members' => nil,
      'version' => 1,
      'changeset_id' => 1,
      'uid' => 1,
      'username' => 'bob',
      'created' => 'today',
      'tags' => {
        'foo' => 'bar',
      },
      'change_distance' => 0,
    }

    diff = TimeMachine.diff_osm_object(nil, after)
    validator.apply(nil, after, diff)
    assert_equal(
      TimeMachine::DiffActions.new(
        attribs: { 'lat' => validation_action, 'lon' => validation_action },
        tags: { 'foo' => validation_action }
      ).inspect,
      diff.inspect
    )

    diff = TimeMachine.diff_osm_object(after, after)
    validator.apply(after, after, diff)
    assert_equal(
      TimeMachine::DiffActions.new(
        attribs: {},
        tags: {}
      ).inspect,
      diff.inspect
    )
  end
end
