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