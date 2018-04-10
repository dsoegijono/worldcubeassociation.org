# frozen_string_literal: true

require 'rails_helper'

RSpec.describe "Competition WCIF" do
  let!(:competition) {
    FactoryBot.create(
      :competition,
      :with_delegate,
      id: "TestComp2014",
      name: "Test Comp 2014",
      cellName: "Test 2014",
      start_date: "2014-02-03",
      end_date: "2014-02-05",
      external_website: "http://example.com",
      showAtAll: true,
      event_ids: %w(333 444 333fm 333mbf),
      with_schedule: true,
    )
  }
  let(:delegate) { competition.delegates.first }
  let(:sixty_second_2_attempt_cutoff) { Cutoff.new(number_of_attempts: 2, attempt_result: 1.minute.in_centiseconds) }
  let(:top_16_advance) { RankingCondition.new(16) }
  let!(:round333_1) { FactoryBot.create(:round, competition: competition, event_id: "333", number: 1, cutoff: sixty_second_2_attempt_cutoff, advancement_condition: top_16_advance, scramble_group_count: 16) }
  let!(:round333_2) { FactoryBot.create(:round, competition: competition, event_id: "333", number: 2) }
  let!(:round444_1) { FactoryBot.create(:round, competition: competition, event_id: "444", number: 1) }
  let!(:round333fm_1) { FactoryBot.create(:round, competition: competition, event_id: "333fm", number: 1, format_id: "m") }
  let!(:round333mbf_1) { FactoryBot.create(:round, competition: competition, event_id: "333mbf", number: 1, format_id: "3") }
  before :each do
    # Load all the rounds we just created.
    competition.reload
  end

  describe "#to_wcif" do
    it "renders a valid WCIF" do
      expect(competition.to_wcif).to eq(
        "formatVersion" => "1.0",
        "id" => "TestComp2014",
        "name" => "Test Comp 2014",
        "shortName" => "Test 2014",
        "persons" => [delegate.to_wcif(competition)],
        "events" => [
          {
            "id" => "333",
            "rounds" => [
              {
                "id" => "333-r1",
                "format" => "a",
                "timeLimit" => {
                  "centiseconds" => 10.minutes.in_centiseconds,
                  "cumulativeRoundIds" => [],
                },
                "cutoff" => {
                  "numberOfAttempts" => 2,
                  "attemptResult" => 1.minute.in_centiseconds,
                },
                "advancementCondition" => {
                  "type" => "ranking",
                  "level" => 16,
                },
                "scrambleGroupCount" => 16,
                "roundResults" => [],
              },
              {
                "id" => "333-r2",
                "format" => "a",
                "timeLimit" => {
                  "centiseconds" => 10.minutes.in_centiseconds,
                  "cumulativeRoundIds" => [],
                },
                "cutoff" => nil,
                "advancementCondition" => nil,
                "scrambleGroupCount" => 1,
                "roundResults" => [],
              },
            ],
          },
          {
            "id" => "333fm",
            "rounds" => [
              {
                "id" => "333fm-r1",
                "format" => "m",
                "timeLimit" => nil,
                "cutoff" => nil,
                "advancementCondition" => nil,
                "scrambleGroupCount" => 1,
                "roundResults" => [],
              },
            ],
          },
          {
            "id" => "333mbf",
            "rounds" => [
              {
                "id" => "333mbf-r1",
                "format" => "3",
                "timeLimit" => nil,
                "cutoff" => nil,
                "advancementCondition" => nil,
                "scrambleGroupCount" => 1,
                "roundResults" => [],
              },
            ],
          },
          {
            "id" => "444",
            "rounds" => [
              {
                "id" => "444-r1",
                "format" => "a",
                "timeLimit" => {
                  "centiseconds" => 10.minutes.in_centiseconds,
                  "cumulativeRoundIds" => [],
                },
                "cutoff" => nil,
                "advancementCondition" => nil,
                "scrambleGroupCount" => 1,
                "roundResults" => [],
              },
            ],
          },
        ],
        "schedule" => {
          "startDate" => "2014-02-03",
          "numberOfDays" => 3,
          "venues" => [
            {
              "id" => 1,
              "name" => "Venue 1",
              "latitudeMicrodegrees" => 123456,
              "longitudeMicrodegrees" => 123456,
              "timezone" => "Europe/Paris",
              "rooms" => [
                {
                  "id" => 1,
                  "name" => "Room 1 for venue 1",
                  "activities" => [
                    {
                      "id" => 1,
                      "name" => "Some name",
                      "activityCode" => "other-lunch",
                      "startTime" => "2014-02-03T12:00:00Z",
                      "endTime" => "2014-02-03T13:00:00Z",
                      "childActivities" => []
                    },
                    {
                      "id" => 2,
                      "name" => "another activity",
                      "activityCode" => "333fm-r1",
                      "startTime" => "2014-02-03T10:00:00Z",
                      "endTime" => "2014-02-03T11:00:00Z",
                      "childActivities" => [
                        {
                          "id" => 3,
                          "name" => "first group",
                          "activityCode" => "333fm-r1-g1",
                          "startTime" => "2014-02-03T10:00:00Z",
                          "endTime" => "2014-02-03T10:30:00Z",
                          "childActivities" => []
                        },
                        {
                          "id" => 4,
                          "name" => "second group",
                          "activityCode" => "333fm-r1-g2",
                          "startTime" => "2014-02-03T10:30:00Z",
                          "endTime" => "2014-02-03T11:00:00Z",
                          "childActivities" => [
                            {
                              "id" => 5,
                              "name" => "some nested thing",
                              "activityCode" => "333fm-r1-g2-a1",
                              "startTime" => "2014-02-03T10:30:00Z",
                              "endTime" => "2014-02-03T11:00:00Z",
                              "childActivities" => []
                            }
                          ]
                        }
                      ]
                    }
                  ]
                }
              ]
            },
            {
              "id" => 2,
              "name" => "Venue 2",
              "latitudeMicrodegrees" => 123456,
              "longitudeMicrodegrees" => 123456,
              "timezone" => "Europe/Paris",
              "rooms" => [
                {
                  "id" => 1,
                  "name" => "Room 1 for venue 2",
                  "activities" => []
                },
                {
                  "id" => 2,
                  "name" => "Room 2 for venue 2",
                  "activities" => []
                }
              ]
            }
          ]
        },
      )
    end
  end

  describe "#set_wcif_events!" do
    let(:wcif) { competition.to_wcif }

    it "does not remove competition event when wcif rounds are empty" do
      wcif_444_event = wcif["events"].find { |e| e["id"] == "444" }
      wcif_444_event["rounds"] = []

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
      expect(competition.events.map(&:id)).to match_array %w(333 333fm 333mbf 444)
    end

    it "does remove competition event when wcif rounds are nil" do
      wcif_444_event = wcif["events"].find { |e| e["id"] == "444" }
      wcif_444_event["rounds"] = nil

      competition.set_wcif_events!(wcif["events"], delegate)

      wcif["events"].reject! { |e| e["id"] == "444" }
      expect(competition.to_wcif["events"]).to eq(wcif["events"])
      expect(competition.events.map(&:id)).to match_array %w(333 333fm 333mbf)
    end

    it "removes competition event when wcif event is missing" do
      wcif["events"].reject! { |e| e["id"] == "444" }

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
      expect(competition.events.map(&:id)).to match_array %w(333 333fm 333mbf)
    end

    it "creates competition event when adding round to previously nonexistent event" do
      wcif["events"] << {
        "id" => "555",
        "rounds" => [
          {
            "id" => "555-r1",
            "format" => "3",
            "timeLimit" => {
              "centiseconds" => 3*60*100,
              "cumulativeRoundIds" => [],
            },
            "cutoff" => nil,
            "advancementCondition" => nil,
            "scrambleGroupCount" => 1,
            "roundResults" => [],
          },
        ],
      }

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end

    it "creates new round when adding round to existing event" do
      wcif_444_event = wcif["events"].find { |e| e["id"] == "444" }
      wcif_444_event["rounds"][0]["advancementCondition"] = {
        "type" => "ranking",
        "level" => 16,
      }
      wcif_444_event["rounds"] << {
        "id" => "444-r2",
        "format" => "a",
        "timeLimit" => {
          "centiseconds" => 10.minutes.in_centiseconds,
          "cumulativeRoundIds" => [],
        },
        "cutoff" => nil,
        "advancementCondition" => nil,
        "scrambleGroupCount" => 1,
        "roundResults" => [],
      }

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])

      # Verify that we can remove the round we just added, so long as we
      # clear the advancementCondition on the first round.
      wcif_444_event["rounds"][0]["advancementCondition"] = nil
      wcif_444_event["rounds"].pop
      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end

    it "can change round format to '3'" do
      wcif_333_event = wcif["events"].find { |e| e["id"] == "333" }
      wcif_333_event["rounds"][0]["format"] = '3'

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end

    it "ignores setting time limit for 333mbf and 333fm" do
      wcif_333mbf_event = wcif["events"].find { |e| e["id"] == "333mbf" }
      wcif_333mbf_event["rounds"][0]["timeLimit"] = {
        "centiseconds" => 30.minutes.in_centiseconds,
        "cumulativeRoundIds" => [],
      }

      wcif_333fm_event = wcif["events"].find { |e| e["id"] == "333fm" }
      wcif_333fm_event["rounds"][0]["timeLimit"] = {
        "centiseconds" => 30.minutes.in_centiseconds,
        "cumulativeRoundIds" => [],
      }

      competition.set_wcif_events!(wcif["events"], delegate)

      wcif_333mbf_event["rounds"][0]["timeLimit"] = nil
      wcif_333fm_event["rounds"][0]["timeLimit"] = nil

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end

    it "can set scrambleGroupCount" do
      wcif_333mbf_event = wcif["events"].find { |e| e["id"] == "333mbf" }
      wcif_333mbf_event["rounds"][0]["scrambleGroupCount"] = 32

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end

    it "can set roundResults" do
      wcif_333_event = wcif["events"].find { |e| e["id"] == "333" }
      wcif_333_event["rounds"][0]["roundResults"] = [
        {
          "personId" => 1,
          "ranking" => 10,
          "attempts" => [{ "result" => 456, "reconstruction" => nil }] * 5,
        },
        {
          "personId" => 2,
          "ranking" => 5,
          "attempts" => [{ "result" => 784, "reconstruction" => nil }] * 5,
        },
      ]

      competition.set_wcif_events!(wcif["events"], delegate)

      expect(competition.to_wcif["events"]).to eq(wcif["events"])
    end
  end

  describe "#set_wcif_schedule!" do
    let(:schedule_wcif) { competition.to_wcif["schedule"] }
    let(:competition_start_time) { competition.start_date.to_datetime }

    context "activities" do
      it "Removing activities works and destroy nested activities" do
        activity_with_child = schedule_wcif["venues"][0]["rooms"][0]["activities"].find { |a| a["id"] == 2 }
        activity_with_child["childActivities"] = []

        competition.set_wcif_schedule!(schedule_wcif, delegate)

        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        expect(ScheduleActivity.all.size).to eq 2
      end

      it "Updating activity's attributes correctly updates the existing object" do
        first_venue = schedule_wcif["venues"][0]
        first_room = first_venue["rooms"][0]
        first_activity = first_room["activities"][0]
        activity_object = competition.competition_venues.find_by(wcif_id: first_venue["id"])
        .venue_rooms.find_by(wcif_id: first_room["id"])
        .schedule_activities.find_by(wcif_id: first_activity["id"])

        first_activity["name"] = "activity name"
        first_activity["activityCode"] = "222-r1"
        first_activity["startTime"] = (activity_object.start_time + 20.minutes).iso8601
        first_activity["endTime"] = (activity_object.end_time + 20.minutes).iso8601
        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        activity_object.reload
        expect(activity_object.name).to eq "activity name"
        expect(activity_object.activity_code).to eq "222-r1"
        expect(activity_object.start_time).to eq first_activity["startTime"]
        expect(activity_object.end_time).to eq first_activity["endTime"]
      end

      it "Creating nested activities works" do
        new_activity = {
          "id" => 44,
          "name" => "2x2 First round",
          "activityCode" => "222-r1",
          "startTime" => competition_start_time.change({ hour: 9, min: 0, sec: 0 }).utc.iso8601,
          "endTime" => competition_start_time.change({ hour: 9, min: 30, sec: 0 }).utc.iso8601,
          "childActivities" => [
            {
              "id" => 45,
              "name" => "2x2 First round group 1",
              "activityCode" => "222-r1-g1",
              "startTime" => competition_start_time.change({ hour: 9, min: 0, sec: 0 }).utc.iso8601,
              "endTime" => competition_start_time.change({ hour: 9, min: 15, sec: 0 }).utc.iso8601,
              "childActivities" => [],
            },
          ],
        }
        schedule_wcif["venues"][0]["rooms"][0]["activities"] << new_activity
        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        competition.reload
        activity = competition.competition_venues.first.venue_rooms.first.schedule_activities.find_by(wcif_id: 44)
        expect(activity.name).to eq "2x2 First round"
        expect(activity.activity_code).to eq "222-r1"
        expect(activity.start_time).to eq new_activity["startTime"]
        expect(activity.end_time).to eq new_activity["endTime"]
        expect(activity.child_activities.size).to eq 1
        child_activity = activity.child_activities.first
        expect(child_activity.wcif_id).to eq 45
        expect(child_activity.name).to eq "2x2 First round group 1"
        expect(child_activity.activity_code).to eq "222-r1-g1"
        expect(child_activity.start_time).to eq new_activity["childActivities"][0]["startTime"]
        expect(child_activity.end_time).to eq new_activity["childActivities"][0]["endTime"]
      end

      it "Doesn't update invalid activity" do
        %w(id name childActivities activityCode startTime endTime).each do |attr|
          save_attr = schedule_wcif["venues"][0]["rooms"][0]["activities"][0][attr]
          schedule_wcif["venues"][0]["rooms"][0]["activities"][0][attr] = nil
          expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(JSON::Schema::ValidationError)
          schedule_wcif["venues"][0]["rooms"][0]["activities"][0][attr] = save_attr
        end
      end

      it "Doesn't update with an invalid activity code" do
        # Try updating an activity with an invalid activity code
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][0]
        activity["activityCode"] = "sneakycode"
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
        competition.reload
        # 'other' is a valid base, but "blabla" is not a valid 'other' activity
        activity["activityCode"] = "other-blabla"
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
        # restore to valid value
        activity["activityCode"] = "other-lunch"
        competition.reload


        # Try updating a nested activity with an invalid activity code
        # The activity is actually 333fm-r1
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        activity["childActivities"] << {
          "id" => 33,
          "name" => "nested with wrong code",
          "activityCode" => "444",
          "startTime" => activity["startTime"],
          "endTime" => activity["endTime"],
          "childActivities" => [],
        }
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "accepts a valid start time from the day before the competition" do
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        # Set the start time to a timezone ahead of UTC (meaning if we transform the
        # time to UTC, the day will actually be the day before the competition).
        # It's fine because at least one timezone had entered the day of the competition.
        activity["startTime"] = competition.start_date.to_datetime.change({ hour: 9, offset: "+0800" }).iso8601
        competition.set_wcif_schedule!(schedule_wcif, delegate)
      end

      it "accepts a valid end time from the day after the competition" do
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        # Set the start time to a timezone behind UTC (meaning if we transform the
        # time to UTC, the day will actually be the day after the competition).
        # It's fine because at least one timezone is still in the last day of the competition.
        activity["endTime"] = competition.end_date.to_datetime.change({ hour: 20, offset: "-0800" }).iso8601
        competition.set_wcif_schedule!(schedule_wcif, delegate)
      end

      it "Doesn't update with an past start time" do
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        activity["startTime"] = (competition.start_date - 1.day).to_datetime.iso8601
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Doesn't update with an future end time" do
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        activity["endTime"] = (competition.end_time + 1.minute).iso8601
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it "Doesn't update a nested activity which is not included in parent" do
        # Let's try first a past date
        activity = schedule_wcif["venues"][0]["rooms"][0]["activities"][1]
        nested_activity = activity["childActivities"][0]
        # Get rid of nested-nested, to make sure we don't run into their validations
        nested_activity["childActivities"] = []
        activity_start = DateTime.parse(activity["startTime"])
        activity_end = DateTime.parse(activity["endTime"])
        nested_activity["startTime"] = (activity_start - 1.minute).iso8601
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
        competition.reload
        nested_activity["startTime"] = activity_start.iso8601
        nested_activity["endTime"] = (activity_end + 1.minute).iso8601
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
        competition.reload
        # Try putting valid start/end time but with end time before start time
        nested_activity["endTime"] = activity_start.iso8601
        nested_activity["startTime"] = activity_end.iso8601
        expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(ActiveRecord::RecordInvalid)
      end
    end

    context "venues" do
      it "Removing venues works and destroys nested rooms and activities" do
        schedule_wcif["venues"] = []

        competition.set_wcif_schedule!(schedule_wcif, delegate)

        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        expect(VenueRoom.all.size).to eq 0
        expect(ScheduleActivity.all.size).to eq 0
      end

      it "Updating venue's attributes correctly updates the existing object" do
        first_venue = schedule_wcif["venues"][0]
        venue_object = competition.competition_venues.find_by(wcif_id: first_venue["id"])


        first_venue["name"] = "new name"
        first_venue["latitudeMicrodegrees"] = 0
        first_venue["longitudeMicrodegrees"] = 0
        first_venue["timezone"] = "Europe/Madrid"

        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        venue_object.reload
        expect(venue_object.name).to eq "new name"
        expect(venue_object.latitude_microdegrees).to eq 0
        expect(venue_object.longitude_microdegrees).to eq 0
        expect(venue_object.timezone_id).to eq "Europe/Madrid"
      end

      it "Creating venue works" do
        schedule_wcif["venues"] << {
          "id" => 44,
          "name" => "My new venue",
          "latitudeMicrodegrees" => 123,
          "longitudeMicrodegrees" => 456,
          "timezone" => "Europe/London",
          "rooms" => [],
        }
        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        competition.reload
        venue = competition.competition_venues.find_by(wcif_id: 44)
        expect(venue.name).to eq "My new venue"
        expect(venue.latitude_microdegrees).to eq 123
        expect(venue.longitude_microdegrees).to eq 456
        expect(venue.timezone_id).to eq "Europe/London"
      end

      it "Doesn't update invalid venue" do
        original_wcif = schedule_wcif.clone
        %w(id name latitudeMicrodegrees longitudeMicrodegrees timezone rooms).each do |attr|
          save_attr = schedule_wcif["venues"][0][attr]
          schedule_wcif["venues"][0][attr] = nil
          expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(JSON::Schema::ValidationError)
          schedule_wcif["venues"][0][attr] = save_attr
        end
      end
    end

    context "rooms" do
      it "Removing rooms works and destroy nested activities" do
        schedule_wcif["venues"][0]["rooms"].delete_at(0)

        competition.set_wcif_schedule!(schedule_wcif, delegate)

        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        expect(ScheduleActivity.all.size).to eq 0
      end

      it "Updating room's attributes correctly updates the existing object" do
        first_venue = schedule_wcif["venues"][0]
        first_room = first_venue["rooms"][0]
        room_object = competition.competition_venues.find_by(wcif_id: first_venue["id"]).venue_rooms.find_by(wcif_id: first_room["id"])

        first_room["name"] = "new room name"
        first_room["activities"] = []
        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        room_object.reload
        expect(room_object.name).to eq "new room name"
        expect(room_object.schedule_activities.size).to eq 0
      end

      it "Creating room works" do
        schedule_wcif["venues"][0]["rooms"] << {
          "id" => 44,
          "name" => "Hippolyte's backyard",
          "activities" => [],
        }
        competition.set_wcif_schedule!(schedule_wcif, delegate)
        expect(competition.to_wcif["schedule"]).to eq(schedule_wcif)
        competition.reload
        room = competition.competition_venues.first.venue_rooms.find_by(wcif_id: 44)
        expect(room.name).to eq "Hippolyte's backyard"
      end

      it "Doesn't update invalid room" do
        original_wcif = schedule_wcif.clone
        %w(id name activities).each do |attr|
          save_attr = schedule_wcif["venues"][0]["rooms"][0][attr]
          schedule_wcif["venues"][0]["rooms"][0][attr] = nil
          expect { competition.set_wcif_schedule!(schedule_wcif, delegate) }.to raise_error(JSON::Schema::ValidationError)
          schedule_wcif["venues"][0]["rooms"][0][attr] = save_attr
        end
      end
    end
  end
end
