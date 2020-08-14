// ---------------- Q Block内购相关语句 ----------------

// 查找Q Block product_id
db.getCollection("Production").find({
    '_id': ObjectId('5d0b3f971cd8ea0001e2473a')
})

// Google内购
// 结果与商店后台有轻微差距，以我们的结果为准
// PBN结果与BI有差距，因为BI国际版数据也包括了中国区，减去中国区的就是正确的国际版数据 ？？？？？？
db.getCollection("GooglePlaySales").aggregate([
    {$match: {'product_id': 'puzzle.blockpuzzle.cube.relax'}},
    {$match: {'date': {$gte: '2020-06-01', $lte: '2020-06-08'}}},
    {$group: {
        '_id': {'product_title': '$product_title', 'date': '$date'},
        'units': {$sum: 1},
        'revenue': {$sum: {$multiply: ['$revenue',0.7]}}
    }},
    {$sort: {'_id.date': 1, '_id.product_title': 1}},
    {$project:{
        'platform': 'Android',
        "date": "$_id.date",
        'title': '$_id.product_title',
        'units': '$units',
        'revenue': '$revenue'
    }}
])

// 分国家或者日期查看Google内购表
db.getCollection("GooglePlaySales").find({
    'product_id': 'puzzle.blockpuzzle.cube.relax',
    'date': {$gte: '2020-06-01', $lte: '2020-06-07'}
})
.sort({'date':1})
.limit(10)

// Apple内购
// 结果与商店后台有轻微差距，以我们的结果为准
// 与BI数据相同，中国区有在使用国际版的人
db.getCollection("AppleSales").aggregate([
    {$match: {'app_apple_id':'1466197423'}},
    {$match: {'report_date': {$gte: '2020-06-01', $lte: '2020-06-08'}}},
    {$group: {
        '_id': {'date': '$report_date', 'title':'$title'},
        'units': {$sum: '$units'},
        // 不同于Google，表中的revenue是每笔单价
        'income': {$sum: {$multiply: ['$proceed', '$units']}}
    }},
    {$sort: {'_id.date': 1, '_id.title': 1}},
    {$project:{
        'platform': 'iOS',
        "date": "$_id.date",
        'title': '$_id.title',
        'units': '$units',
        'income': '$income'
    }}
])

// 分国家或者日期查看Apple内购表
db.getCollection("AppleSales").aggregate([
    {$match: {'app_apple_id':'1466197423'}},
    {$match: {'country_code': 'CN'}},
    {$match: {'report_date': {$gte: '2020-06-01', $lte: '2020-06-07'}}},
    {$group: {'_id': {'title':'$title','sku':'$sku'}}},
    {$sort: {'_id.title':1}}
])


// PBN内购数据
db.AppleSales.aggregate([
    {$facet: {
        "apple_revenue":[
            {$lookup: {
                'from':'AppleSales',
                'pipeline': [
                    {$match: {'app_apple_id':'1466197423'}},
                    {$match: {'report_date': {$gte: '2020-06-01', $lte: '2020-06-07'}}},
                    {$group: {
                        '_id': {'date': '$report_date', 'sku':'$title'},
                        'units': {$sum: '$units'},
                        // 不同于Google，表中的revenue是每笔单价
                        'revenue': {$sum: {$multiply: ['$revenue', '$units']}}
                    }},
                    {$sort: {'_id.date': 1, '_id.title': 1}},
                    {$project: {
                        '_id': 0,
                        'platform': 'Android',
                        'date': '$_id.date',
                        'sku': '$_id.sku',
                        'units': '$units',
                        'revenue': '$revenue'
                    }}
                ],
                'as': 'apple_revenue'
            }}
        ],
        'google_revenue':[
            {$lookup:{
                'from': 'GooglePlaySales',
                'pipeline':[
                    {$match: {'product_id': 'puzzle.blockpuzzle.cube.relax'}},
                    {$match: {'date': {$gte: '2020-06-01', $lte: '2020-06-07'}}},
                    {$group: {
                        '_id': {'date': '$date', 'sku': '$product_title'},
                        'units': {$sum: 1},
                        'revenue': {$sum: '$revenue'}
                    }},
                    {$sort: {'_id.date': 1, '_id.product_title': 1}},
                    {$project: {
                        '_id': 0,
                        'platform': 'iOS',
                        'date': '$_id.date',
                        'sku': '$_id.sku',
                        'units': '$units',
                        'revenue': '$revenue'
                    }}
                ],
                'as': 'google_revenue'
            }}
        ]  
    }}
])
