#如果系统存在文件名相同，但路径不同的文件，如果单纯用find来批量复制到一个地方的话会被覆盖掉，下面的脚本是实现根据文件名的路径来进行存放复制。为能更好的测试，脚本中加了在不同路径创建相同文件名的程序。

    #!/bin/sh
    . /etc/profile
    # define
    tf=testfile
    destpath=/root/found
    [ ! -d $destpath ] && mkdir -p $destpath
    # touch some the same file for test
    TouchFile()
    { 
    echo "/tmp" > /tmp/$tf
    echo "/home" > /home/$tf
    echo "/root" > /root/$tf
    echo "/var/tmp" > /var/tmp/$tf
    }
    # find the file and copy to the dest dir
    FindCopy()
    {
    TouchFile
    if [ $? -eq 0 ];then
        for i in $(find / -name $tf);do
            [ ! -d $destpath/$(dirname $i) ] && mkdir -p $destpath$(dirname $i)
            cp -rf $i $destpath$(dirname $i) 
            #echo $i
        done
    else
        echo "please touch some test file first..."
    fi
    }
    FindCopy

