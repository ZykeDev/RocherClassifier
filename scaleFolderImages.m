function result = scaleFolderImages(fpath, newfpath, scale)
fpath = strcat(fpath, "/");
newfpath = strcat(newfpath, "/");

files = dir(strcat(fpath), '*.JPG');

for k = 1 : length(files)
    name = files(k).name;
    path = strcat(fpath, name);
    im = imresize(imread(path), scale);
    destPath = strcat(newfpath, sprintf(name));
    imwrite(im, destPath);
end

result = 1;
end

