#!/usr/bin/python3
# Parses a comps XML file and an environment-id to
# list all packages for the specified environment.
# This script does not depsolve and is meant for
# helping customizing images with kickstart.
#
# Originally written by Colin Walters <walters@verbum.org>
# Copyright (C) 2010 Red Hat, Inc.
#
# Modified by Samuel Imboden <imboden.samuel@protonmail.ch>
# Copyright (C) 2025 Samuel Imboden
#
# Licensed under the new-BSD license (http://www.opensource.org/licenses/bsd-license.php)

import sys
import getopt
import xml.etree.ElementTree as ElementTree
from  xml.etree.ElementTree import Element

def usage(ecode):
    print("Usage: {} COMPS.xml ENVIRONMENT".format(sys.argv[0]))
    print("List packages installed by KICKSTART.")
    sys.exit(ecode)

def get_groups(root: Element, group_node: Element) -> dict[str, list[str]]:
    packages_for_group = {}
    for group_id in group_node:
        group = root.find(f".//id[.=\"{group_id.text}\"]/..")
        assert group is not None
        pkglist_node = group.find('packagelist')
        assert pkglist_node is not None
        reqs = pkglist_node.findall('packagereq')
        pkglist = []
        for req in reqs:
            if req.attrib.get('type', 'default') in ('default', 'mandatory'):
                pkglist.append(req.text)
        packages_for_group[group_id.text] = pkglist
    return packages_for_group

def get_packages(groups: dict[str, list[str]], debug=False) -> set[str]:
    pkg_list = set()
    for group_id, pkgs in groups.items():
        if debug:
            print(f"# Including {len(pkgs)} from group {group_id}",file=sys.stderr)
        pkg_list.update(pkgs)
    return pkg_list

def main():
    try:
        opts, args = getopt.getopt(sys.argv[1:], 'h', ['help', 'debug', 'optional'])
    except getopt.GetoptError as e:
        usage(1)
    debug = False
    include_optional = False
    for o, a in opts:
        if o in ('-h', '--help'):
            usage(0)
        elif o in ('--debug',):
            debug = True
        elif o in ('--optional'):
            include_optional = True
    if len(args) != 2:
        usage(1)
    comps_filename = args[0]
    env_id = args[1]
    comps = ElementTree.parse(comps_filename)
    env = comps.find(f".//id[.=\"{env_id}\"]/..")
    assert env is not None
    req_groups = get_groups(comps, env.find('grouplist'))
    op_groups = get_groups(comps, env.find('optionlist'))
    pkg_list = get_packages(req_groups, debug)
    if include_optional:
        pkg_list.update(get_packages(op_groups, debug))
    for pkg in sorted(pkg_list,key=str.lower):
        print(pkg)
    sys.exit(0)

if __name__ == '__main__':
    main()