# Slices

## S1. See a parent and a spouse on the tree

Done when: a person can register people, link a parent and a spouse, and see them on the tree, the child one generation below the parent. After each save, the tree shows the graph just read. That graph is everyone stored.

The rank for a parent cycle, for a child of two parents, and for spouses whose ranks differ, is S4.

Consumes: AD-01, AD-02, AD-03, AD-06

Blocked by: none

Issue: https://github.com/lukec3x/ancestor-graph/issues/1

## S2. Correct a person and see a refused write

Done when: a person can open someone on the tree, replace that person's fields, and see the change on the tree. A refused write shows one error envelope and leaves the graph unchanged. The refusals are a bad sex, a bad date, a link from a person to themselves, a missing person or union, and a body that is not the contract.

Consumes: AD-03, AD-04, AD-05, AD-06

Blocked by: S1

Issue: https://github.com/lukec3x/ancestor-graph/issues/2

## S3. Attribute a child to a union

Done when: a person can link a child to a parent and to a union that a spouse link already created, and see that attribution on the tree.

Consumes: AD-03

Blocked by: S1

Issue: https://github.com/lukec3x/ancestor-graph/issues/3

## S4. See a parent cycle, the higher parent, and spouses on their own ranks

Done when: a person can record a parent cycle and see those people share one rank. A child of two parents sits one generation below the higher parent. Two spouses whose ranks differ stay on their own ranks.

Consumes: AD-02

Blocked by: S1

Issue: https://github.com/lukec3x/ancestor-graph/issues/4
