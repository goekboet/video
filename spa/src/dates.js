import formatDistance from 'date-fns/formatDistance'
import setMonth from 'date-fns/setMonth'
import setDate from 'date-fns/setDate'
import isAfter from 'date-fns/isAfter'
import addYears from 'date-fns/addYears'

let toChristmas = () => {
    let now = new Date()
    let thisChristmas = setDate(setMonth(now, 11), 24)
    let nextChristmas = isAfter(now, thisChristmas)
        ? addYears(thisChristmas, 1)
        : thisChristmas
    
    return formatDistance(nextChristmas, now, { includeSeconds: true })
}

export { toChristmas }