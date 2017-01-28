function out_str = VAPP_file_to_str(infile_path)

    fid = fopen(infile_path, 'r');
    out_str = '';

    while true

        % don't use fgets below: with fgets, random things happen with files 
        % that don't have proper UNIX-style line endings; instead, fgetl gets
        % you lines without the trailing newline character, so you can add a
        % proper sprintf('\n') character yourself.
        l = fgetl(fid);

        if l == -1 % end of file reached
            break;
        end

        out_str = [out_str, l, sprintf('\n')];

    end

    fclose(fid);

end

