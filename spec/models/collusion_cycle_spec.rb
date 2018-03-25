describe CollusionCycle do
  ###
  # Please do not share this file with other teams.
  # Use factories to `build` necessary objects.
  # Please avoid duplicated code as much as you can by moving the code to `before(:each)` block or separated methods.
  # RSpec tutorial video (until 9:32): https://youtu.be/dzkVfaKChSU?t=35s
  # RSpec unit tests examples: https://github.com/expertiza/expertiza/blob/3ce553a2d0258ea05bced910abae5d209a7f55d6/spec/models/response_spec.rb
  ###

  #
  # assignment participant ────┐
  #    ∧                       │
  #    │                       v
  #    └───────────────────── current reviewer (ap)
  #

  let(:response) { build(:response) }
  let(:team) { build(:assignment_team, id: 1, name: "team1", assignment: assignment) }
  let(:team2) { build(:assignment_team, id: 2, name: "team2", assignment: assignment) }
  let(:participant) { build(:participant, id: 1, assignment: assignment) }
  let(:participant2) { build(:participant, id: 2, grade: 90) }
  let(:participant3) { build(:participant, id: 3) }
  let(:participant4) { build(:participant, id: 4) }
  let(:assignment) { build(:assignment, id: 1) }
  let(:response_map_no_response) { build(:review_response_map, id: 1, reviewee_id: team.id, reviewer_id: participant2.id, assignment: assignment) }
  let(:response_map_response) { build(:review_response_map, id: 2, reviewee_id: team2.id, reviewer_id: participant.id, response: [response], assignment: assignment) }
  let(:response_map_response2) { build(:review_response_map, id: 3, reviewee_id: team.id, reviewer_id: participant2.id, response: [response], assignment: assignment) }
  
  before(:each) do
    allow(participant).to receive(:team).and_return(team)
    allow(participant2).to receive(:team).and_return(team2)
    @cycle = CollusionCycle.new()
  end

  describe '#two_node_cycles' do
    context 'when the reviewers of current reviewer (ap) does not include current assignment participant' do
      it 'skips this reviewer (ap) and returns corresponding collusion cycles' do
        #Sets up variables for test
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_no_response])
        allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
        allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([])
        
        #Tests if current reviewer does not include current assignment participant
        expect(@cycle.two_node_cycles(participant)).to eql([])
      end
    end

    context 'when the reviewers of current reviewer (ap) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by current reviewer (ap)' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles' do
          #Sets up variables for test
          participant.grade = 100
          participant2.assignment = assignment
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_no_response])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_response])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_no_response])
          
          #Tests if current assignment participant was not reviewed by current reviewer
          expect(@cycle.two_node_cycles(participant)).to eql([])
        end
      end

      context 'when current assignment participant was reviewed by current reviewer (ap)' do
        it 'inserts related information into collusion cycles and returns results' do
          #Sets up variables for test
          participant.grade = 100
          participant2.assignment = assignment
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team.id).and_return([response_map_response2])
          allow(AssignmentParticipant).to receive(:find).with(2).and_return(participant2)
          allow(ReviewResponseMap).to receive(:where).with('reviewee_id = ?', team2.id).and_return([response_map_response])
          allow(AssignmentParticipant).to receive(:find).with(1).and_return(participant)
          allow(ReviewResponseMap).to receive(:where).with(reviewee_id: team.id, reviewer_id: participant2.id).and_return([response_map_response2])
          
          #Tests if current assignment participant was reviewed by current reviewer and insert related information into collusion cycles array
          expect(@cycle.two_node_cycles(participant)).to eql([[participant, 90], [participant2, 100]])
        end
      end

      context 'when current reviewer (ap) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewer (ap) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end
    end
  end

  #
  # assignment participant ────┐
  #    ∧                       │
  #    │                       v
  # current reviewee (ap1) <─ current reviewer (ap2)
  #
  describe '#three_node_cycles' do
    context 'when the reviewers of current reviewer (ap2) does not include current assignment participant' do
      it 'skips this reviewer (ap2) and returns corresponding collusion cycles'
      # Write your test here!
    end

    context 'when the reviewers of current reviewer (ap2) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by current reviewee (ap1)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current assignment participant was reviewed by current reviewee (ap1)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewee (ap1) was not reviewed by current reviewer (ap2)' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewee (ap1) was reviewed by current reviewer (ap2)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewer (ap2) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap2) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewer (ap2) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end
    end
  end

  #
  #             assignment participant ─> current reviewer (ap3)
  #                                ∧       │
  #                                │       v
  # reviewee of current reviewee (ap1) <─ current reviewee (ap2)
  #
  describe '#four_node_cycles' do
    context 'when the reviewers of current reviewer (ap3) does not include current assignment participant' do
      it 'skips this reviewer (ap3) and returns corresponding collusion cycles'
      # Write your test here!
    end

    context 'when the reviewers of current reviewer (ap3) includes current assignment participant' do
      context 'when current assignment participant was not reviewed by the reviewee of current reviewee (ap1)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current assignment participant was reviewed by the reviewee of current reviewee (ap1)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when the reviewee of current reviewee (ap1) was not reviewed by current reviewee (ap2)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when the reviewee of current reviewee (ap1) was reviewed by current reviewee (ap2)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewee (ap2) was not reviewed by current reviewer (ap3)' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewee (ap2) was reviewed by current reviewer (ap3)' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end

      context 'when current reviewer (ap3) was not reviewed by current assignment participant' do
        it 'skips current reviewer (ap3) and returns corresponding collusion cycles'
        # Write your test here!
      end

      context 'when current reviewer (ap3) was reviewed by current assignment participant' do
        it 'inserts related information into collusion cycles and returns results'
        # Write your test here!
      end
    end
  end

  describe '#cycle_similarity_score' do
    it 'returns similarity score based on inputted cycle'
    # Write your test here!
  end

  describe '#cycle_deviation_score' do
    it 'returns cycle deviation score based on inputted cycle'
    # Write your test here!
  end
end
