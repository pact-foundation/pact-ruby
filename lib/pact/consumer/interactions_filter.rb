#
# When running in pactfile_write_mode :overwrite, all interactions are cleared from the
# pact file, and all new interactions should be distinct (unique description and provider state).
# When running in pactfile_write_mode :update, an interaction with the same description
# and provider state as an existing one will just overwrite that one interaction.
#

module Pact
   module Consumer

      #TODO: think of a better word than filter
      class InteractionsFilter
         def initialize interactions = []
            @interactions = interactions
         end

         def index_of interaction
            @interactions.find_index{ |i| i.matches_criteria?(description: interaction.description, provider_state: interaction.provider_state)}
         end
      end

      class UpdatableInteractionsFilter < InteractionsFilter

         def << interaction
            if (ndx = index_of(interaction))
               @interactions[ndx] = interaction
            else
               @interactions << interaction
            end
         end

      end

      class DistinctInteractionsFilter < InteractionsFilter

         def << interaction
            if (ndx = index_of(interaction))
               if @interactions[ndx] != interaction
                  raise "Interaction with same description (#{interaction.description}) and provider state (#{interaction.provider_state}) already exists"
               end
            else
               @interactions << interaction
            end
         end
      end

   end
end