module Pact
   module Consumer
      # Could use a set but displaying and to_json functionality is better with an Array
      class UpdatableInteractions < Array

         def initialize list = []
            super()
            concat list            
         end

         def concat list
            list.each {|interaction| self << interaction}
         end

         def << interaction
            if (ndx = index(interaction)) 
               self[ndx] = interaction
            else
               super
            end
         end

         def include? interaction
            index(interaction) != nil
         end

         def index interaction
            find_index{ |i| i.matches_criteria?(description: interaction.description, provider_state: interaction.provider_state)}
         end
      end

      class DistinctInteractions < UpdatableInteractions

         def << interaction
            if (ndx = index(interaction))
               if self[ndx] != interaction
                  raise "Interaction with same description (#{interaction.description}) and provider state (#{interaction.provider_state}) already exists"
               end
            else
               super
            end
         end
      end

   end
end