+++
title = "@primaryKey Directive"
description = "The @primaryKey directive allows a group of string fields to be specified as collectively unique."
weight = 12
[menu.main]
parent = "schema"
+++

Here's the GraphQL definition of the directives:

```graphql
directive @primaryKey(fields: [String]) on OBJECT
```
Syntax:
```graphql
type StudentGrades @primaryKey(fields: ["studentNumber", "subjectCode"]) {
    id: ID!
    studentNumber: String! @search
    courseCode: String! @search
    score: Float!
}
```

[https://www.apollographql.com/docs/federation/federation-spec/#key](https://www.apollographql.com/docs/federation/federation-spec/#key)

currently, multiple @id colums can be specified on a schema. The @id directive specifies uniqueness across the database.

An example of where this might be used is to enforce uniqueness of a user’s username field, and the users email field. each field must be unique across the database.

It does not specify that the combination of username and email must be unique.

There are times when we want to be able to enforce a composite key, meaning that only the combination of values is unique across the database, not the individual field values themselves.

An example may be storing the grades that students achieved in their courses.

A student must only have 1 grade per course they take, and so in a grades entity, we could define a composite key to enforce the uniqueness constraint.



for the example, let’s assume we have the following data already in the database

| id | student | course | grade |
| --- | --- | --- | --- |
| 0x1 | Geoff Nunan | Physics101 | D |
| 0x2 | Geoff Nunan | Maths101 | D |

Schema Generation

| Type     | Name | Arguments | Example                                                                                                                      | Comments                                                                                                                                                                                                                                                                                                                                                                                   |
|----------| --- | --- |------------------------------------------------------------------------------------------------------------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Query    | getGrade | Each of the key fields should be added as arguments. All of the key fields should be required, or the ID type field. | getGrade(id:”0x123”){ student, course, grade } or getGrade(student:”Geoff Nunan”, course:”Physics101”){student, course, grade} |                                                                                                                                                                                                                                                                                                                                                                                            |
| Query    | queryGrade | all of the key fields should be searchable | queryGrade(filter:{course:{eq:”Physics101”}})                                                                                | should return all records that match the course Physics101. @search needs to be added to each field to make it searchable                                                                                                                                                                                                                                                                  |                                                                                                                      |
| Mutation | addGrade | all of the key fields are required. This should be in the schema validation. If a key field is defined, it must be a required field. |                                                                                                                              |                                                                                                                                                                                                                                                                                                                                                                                            |
| Input    | GradeFilter | All of the key fields should be added to the Filter. |                                                                                                                              | It should be possible to update using only part of the key field set. Example, update filter by product name will update all products where name is a match regardless of version                                                                                                                                                                                                          |
| Mutation | updateGrade | filter, set, remove | updateGrade(filter:{student:{eq:”Geoff Nunan”}}, set:{course:”Maths101”}){ student, course, grade }                          | This should fail because it would try to create a duplicate composite key. The processing would be as follows: - query all subjects according to the filter - for each returned subject, update the course to Maths101. Two subjects should be returned, 0x1, and 0x2. When 0x1 is updated to course=Maths101, this should fail as there is already a matching row for that composite key. | |
| Mutation | updateGrade | filter, set, remove | updateGrade(filter:{student:{eq:”Geoff Nunan”}},set:{grade:”HD”}){student,course,grade} | This should succeed, and result in all Geoff Nunan’s grades being updated to HD                                                                                                                                                                                                                                                                                                            |
| Mutation | deleteGrade | filter | deleteGrade(filter: {student: {eq: “Geoff Nunan”}}) {msg numUids}| It would be possible to delete using - any of the fields that are part of a composite index - or using the combination of all fields that are part of the index                                                                                                                                                                                                                            |

## Update Mutations with composite keys
When you perform an update on a type that has a composite key, all of the key fields need to be specified either as part of a `filter` or in the `set`

## Restrictions / Roadmap

Our default directive is still in beta and we are improving it quickly.  Here's a few points that we plan to work on soon:

* primaryKey fields can only be String! type fields. We will extend this to all other types including relationships

---
