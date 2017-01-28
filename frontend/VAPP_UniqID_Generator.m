classdef VAPP_UniqID_Generator < handle

    properties
        next_uniqID;
    end

    methods

        function self = VAPP_UniqID_Generator()
            % constructor
            self.next_uniqID = 1;
        end

        function out = get_uniqID(self)
            out = self.next_uniqID;
            self.next_uniqID = self.next_uniqID + 1;
        end

    end

end

