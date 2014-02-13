#. PLATFORM -={
#. Internals -={
function boph:os.arch() {
    local -i e=1
    if [ -x /usr/bin/oslevel ]; then
        uname -p
        e=$?
    else
        uname -m
        e=$?
    fi
    return $e
}

function boph:os.shorthost() {
    local -i e=1
    local hn

    if [ "$OS_TYPE" != 'AIX' ]; then
        hn="$(hostname -s)"
        e=$?
    else
        domain="$(awk '/domain/{print$2}' /etc/resolv.conf)"
        hn="$(hostname)"
        e=$?
        hn="${hn%%.${domain}}"
    fi

    echo "${hn}"
    return $e
}

function boph:os.vendor() {
    local -i e=0

    local os_dist=Unknown
    if [ -e /etc/redhat-release ]; then
        os_dist='RedHat'
        grep -qi 'red hat' /etc/redhat-release && os_dist='RHEL'
        grep -qi 'fedora' /etc/redhat-release && os_dist='Fedora'
        grep -qi 'centos' /etc/redhat-release && os_dist='CentOS'
    elif [ -e /etc/SuSE-release ]; then
        os_dist='SLES'
    elif [ -e /var/lib/dpkg/info/debianutils.list ]; then
        os_dist='Debian'
    elif [ -e /etc/lsb-release ]; then
        os_dist='Debian'
        grep -qi 'ubuntu' /etc/lsb-release && os_dist='Ubuntu'
    elif [ -e /etc/arch-release ]; then
        os_dist='Arch'
    elif [ -x /usr/bin/sw_vers ]; then
        /usr/bin/sw_vers -productName | grep -qi 'Mac OS X' && os_dist='Apple'
    elif [ -x /usr/bin/oslevel ];then
        os_dist=`/usr/bin/uname -s`
    else
        e=1
    fi

    echo "${os_dist}"
    return $e
}

function boph:os.version() {
    local -i e=0
    local osdescr
    local osvermjr
    local osvermnr
    local osver
    if [ -e /etc/redhat-release ]; then
        osdescr=`cat /etc/redhat-release`
        osvermjr=`echo $osdescr | sed 's/.*release\s\+\([0-9]\+\).*/\1/i'`
        if [ "$osvermjr" -eq 5 ]; then
            osvermnr=`echo $osdescr | sed 's/.*release\s\+[0-9]\+\.\([0-9]\+\).*/\1/i'`
        else
            osvermnr=`echo $osdescr | sed 's/.*update\s\([0-9]\+\).*/\1/i'`
        fi
        grep -qi fedora /etc/redhat-release && osver=$osvermjr || osver="$osvermjr.$osvermnr"
    elif [ -e /etc/SuSE-release ]; then
        osvermjr=`cat /etc/SuSE-release | awk '/VERSION/ {print $3}'`
        osvermnr=`cat /etc/SuSE-release | awk '/PATCHLEVEL/ {print $3}'`
        osver="$osvermjr.$osvermnr"
    elif [ -e /etc/arch-release ]; then
        osvermjr=0
        osvermnr=0
        osver="$osvermjr.$osvermnr"
    elif [ -e /etc/lsb-release ]; then
        . /etc/lsb-release
        osvermjr=${DISTRIB_RELEASE%%.[0-9]*}
        osvermnr=${DISTRIB_RELEASE#[0-9]*.}
        osver="$osvermjr.$osvermnr"
    elif [ -e /etc/debian_version ]; then
        osver=`cat /etc/debian_version`
    elif [ -x /usr/bin/sw_vers ]; then
        osver=`/usr/bin/sw_vers -productVersion`
    elif [ -x /usr/bin/oslevel ]; then
        osvermjr=`/usr/bin/uname -v`
        osvermnr=`/usr/bin/uname -r`
        osver="$osvermjr.$osvermnr"
    else
        e=1
    fi

    echo "$osver"
    return $e
}

function hw:vendor() {
    local -i e=0

    local hwv
    if [ -x /usr/sbin/system_profiler ]; then
        hwv="$(/usr/sbin/system_profiler SPHardwareDataType | awk -F': ' '/Model Name/{print$2}')"
    elif [ -x /usr/bin/oslevel ]; then
        hwv="$(uname -M)"
    else
        local pcilist
        e=1
        if [ -e /usr/bin/lspci ]; then
            pcilist="$(/usr/bin/lspci -v | grep Subsystem)"
            e=$?
        elif [ -e /sbin/lspci ]; then
            pcilist="$(/sbin/lspci -v | grep Subsystem)"
            e=$?
        elif [ -e /usr/sbin/lspci ]; then
            pcilist="$(/usr/sbin/lspci -v | grep Subsystem)"
            e=$?
        fi

        if [ $e -eq 0 ]; then
            if   echo "${pcilist}" | grep -qi 'compaq';          then hwv='CQ'
            elif echo "${pcilist}" | grep -qi 'hewlett-packard'; then hwv='HP'
            elif echo "${pcilist}" | grep -qi 'ibm';             then hwv='IBM'
            elif echo "${pcilist}" | grep -qi 'vmware';          then hwv='VMware'
            elif echo "${pcilist}" | grep -qi 'dell';            then hwv='Dell'
            elif echo "${pcilist}" | grep -qi 'apple';           then hwv='Apple'
            elif echo "${pcilist}" | grep -qi 'qumranet';        then hwv='KVM'
            elif grep -q QEMU /proc/cpuinfo;                     then hwv='KVM'
            else                                                      hwv='Unknown'
                e=1
            fi
        fi
    fi

    echo "${hwv}"
    return $e
}
#. }=-
OS_ARCH=$(boph:os.arch)
OS_HOST=$(boph:os.shorthost)
OS_VENDOR=$(boph:os.vendor)
OS_VERSION=$(boph:os.version)
HW_VENDOR=$(boph:hw.vendor)

function :boph:platform.os_arch() {
    : ${OS_ARCH?}

    local -A symbols=(
        [x86_64]='='
        [i386]='-'
    )

    echo ${symbols[${OS_ARCH}]}
}

function :boph:platform.os_str() {
    : ${OS_VENDOR?}
    : ${OS_VERSION?}

    local -A symbols=(
        [Debian]="${COLORS[LightMagenta]}D"
        [Fedora]="${COLORS[Blue]}F"
        [RHEL]="${COLORS[Red]}R"
        [CentOS]="${COLORS[Cyan]}C"
        [SLES]="${COLORS[LightGreen]}S"
        [Arch]="${COLORS[LightCyan]}A"
        [Ubuntu]="${COLORS[Brown]}U"
    )

    echo ${COLORS[IBlack]}@${symbols[${OS_VENDOR}]}${OS_VERSION}
}

function :boph:platform.hw_vendor() {
    : ${HW_VENDOR?}

    local -A symbols=(
        [IBM]="${COLORS[DarkGray]}i"
        [HP]="${COLORS[Blue]}h"
        [KVM]="${COLORS[Brown]}k"
        [VMware]="${COLORS[LightBlue]}v"
    )

    echo ${symbols[${HW_VENDOR}]}
}
#. }=-
