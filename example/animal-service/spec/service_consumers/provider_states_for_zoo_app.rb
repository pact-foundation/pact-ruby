Pact.provider_states_for "Zoo App" do
  provider_state "there are alligators" do
    set_up do
      #AlligatorRepo.save(Alligator.name("Mary"))
    end

  end

  provider_state "there is not an alligator named Mary" do
    no_op
  end
end